#include "asgn4_helper_funcs.h"
#include "connection.h"
#include "request.h"
#include "response.h"
#include "queue.h"

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pthread.h>
#include <sys/file.h>
#include <getopt.h>

void handle_connection(int);
void handle_get(conn_t *);
void handle_put(conn_t *);
void handle_unsupported(conn_t *);

static queue_t *q;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

bool exist(char *uri) {
    return access(uri, F_OK) != -1;
}

void audit_log(char *oper, char *uri, uint16_t status, int id) {
    fprintf(stderr, "%s,/%s,%d,%d\n", oper, uri, status, id);
}

int requestId(conn_t *conn) {
    char *id = conn_get_header(conn, "Request-Id");
    if (id == NULL) {
        return 0;
    }
    return atoi(id);
}

void do_work(void) {
    while (1) {
        uintptr_t next_socket = 0;
        queue_pop(q, (void **) &next_socket);
        handle_connection(next_socket);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        warnx("wrong arguments: %s port_num", argv[0]);
        fprintf(stderr, "usage: %s <port>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int thread_size = 4;
    int opt;
    while ((opt = getopt(argc, argv, "t:")) != -1) {
        switch (opt) {
        case 't': thread_size = atoi(optarg); break;
        default: exit(EXIT_FAILURE);
        }
    }

    char *endptr = NULL;
    size_t port = (size_t) strtoull(argv[argc - 1], &endptr, 10);

    if (endptr && *endptr != '\0') {
        warnx("invalid port number: %s", argv[argc - 1]);
        return EXIT_FAILURE;
    }

    q = queue_new(thread_size);

    signal(SIGPIPE, SIG_IGN);
    Listener_Socket sock;
    listener_init(&sock, port);
    pthread_t thread[thread_size];

    for (int i = 0; i < thread_size; i++) {
        pthread_create(&thread[i], NULL, (void *(*) (void *) ) do_work, NULL);
    }
    while (1) {
        uintptr_t connfd = listener_accept(&sock);
        queue_push(q, (void *) connfd);
    }

    return EXIT_SUCCESS;
}

void handle_connection(int connfd) {
    conn_t *conn = conn_new(connfd);
    const Response_t *res = conn_parse(conn);

    if (res != NULL) {
        conn_send_response(conn, res);
    } else {
        // debug("%s", conn_str(conn));
        const Request_t *req = conn_get_request(conn);

        if (req == &REQUEST_GET) {
            handle_get(conn);
        } else if (req == &REQUEST_PUT) {
            handle_put(conn);
        } else {
            handle_unsupported(conn);
        }
    }

    close(connfd);
    conn_delete(&conn);
    return;
}

void handle_get(conn_t *conn) {
    // TODO: Implement GET

    char *uri = conn_get_uri(conn);
    const Response_t *response = NULL;

    int fd = open(uri, O_RDONLY, 0600);
    pthread_mutex_lock(&mutex);
    flock(fd, LOCK_EX);
    pthread_mutex_unlock(&mutex);

    struct stat fileStat;
    fstat(fd, &fileStat);
    if (fd < 0) {
        //fd = open(uri, O_RDONLY);
        if (errno == ENOENT) {
            response = &RESPONSE_NOT_FOUND;
            conn_send_response(conn, response);
            audit_log("GET", uri, response_get_code(response), requestId(conn));
            close(fd);
            return;
        } else if (errno == EACCES) {
            response = &RESPONSE_FORBIDDEN;
            conn_send_response(conn, response);
            audit_log("GET", uri, response_get_code(response), requestId(conn));
            close(fd);
            return;
        } else {
            response = &RESPONSE_INTERNAL_SERVER_ERROR;
            conn_send_response(conn, response);
            audit_log("GET", uri, response_get_code(response), requestId(conn));
            close(fd);
            return;
        }
    }

    if (S_ISDIR(fileStat.st_mode)) {
        response = &RESPONSE_FORBIDDEN;
        conn_send_response(conn, response);
        audit_log("GET", uri, response_get_code(response), requestId(conn));
        close(fd);
        return;
    }

    uint64_t fs = fileStat.st_size;
    response = conn_send_file(conn, fd, fs);
    if (response == NULL) {
        response = &RESPONSE_OK;
    }
    audit_log("GET", uri, response_get_code(response), requestId(conn));
    close(fd);
    return;
}

void handle_put(conn_t *conn) {
    // TODO: Implement PUT
    pthread_mutex_lock(&mutex);
    char *uri = conn_get_uri(conn);

    bool is_new = !exist(uri);
    int fd = open(uri, O_WRONLY | O_CREAT, 0644);
    flock(fd, LOCK_EX);

    struct stat fileStat;
    uint16_t code;
    char *id;
    char *oper = "PUT";
    fstat(fd, &fileStat);
    int r_id;
    id = conn_get_header(conn, "Request-Id");
    if (id == NULL) {
        r_id = 0;
        ;
    }
    r_id = atoi(id);

    if (S_ISDIR(fileStat.st_mode)) {
        pthread_mutex_unlock(&mutex);
        code = response_get_code(&RESPONSE_FORBIDDEN);
        conn_send_response(conn, &RESPONSE_FORBIDDEN);
        audit_log(oper, uri, code, r_id);
        close(fd);
        return;
    } else {
        //bool is_new = !exist(uri);
        //fd = open(uri, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (access(uri, F_OK) == -1) {
            if (errno == EACCES) {
                pthread_mutex_unlock(&mutex);
                code = response_get_code(&RESPONSE_FORBIDDEN);
                conn_send_response(conn, &RESPONSE_FORBIDDEN);
                audit_log(oper, uri, code, r_id);
                close(fd);
                return;
            } else if (errno == ENOENT) {
                pthread_mutex_unlock(&mutex);
                code = response_get_code(&RESPONSE_NOT_FOUND);
                conn_send_response(conn, &RESPONSE_NOT_FOUND);
                audit_log(oper, uri, code, r_id);
                close(fd);
                return;
            } else {
                pthread_mutex_unlock(&mutex);
                code = response_get_code(&RESPONSE_INTERNAL_SERVER_ERROR);
                conn_send_response(conn, &RESPONSE_INTERNAL_SERVER_ERROR);
                audit_log(oper, uri, code, r_id);
                close(fd);
                return;
            }
        } else {
            if (is_new) {
                pthread_mutex_unlock(&mutex);
                ftruncate(fd, 0);
                conn_recv_file(conn, fd);
                code = response_get_code(&RESPONSE_CREATED);
                conn_send_response(conn, &RESPONSE_CREATED);
                audit_log(oper, uri, code, r_id);
                close(fd);

                return;
            } else {
                pthread_mutex_unlock(&mutex);
                ftruncate(fd, 0);
                conn_recv_file(conn, fd);
                code = response_get_code(&RESPONSE_OK);
                conn_send_response(conn, &RESPONSE_OK);
                audit_log(oper, uri, code, r_id);

                close(fd);

                return;
            }
        }
    }

    return;
}

void handle_unsupported(conn_t *conn) {

    conn_send_response(conn, &RESPONSE_NOT_IMPLEMENTED);
    return;
}
