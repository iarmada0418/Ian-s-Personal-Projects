#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>
#include <netdb.h>
#include <time.h>
#include <sys/time.h>
#include <sys/select.h>
#include <signal.h>

// Include SSL headers
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>

//#define LISTEN_PORT 8080
#define BUFFER_SIZE 1024
#define MAX_WORD_LENGTH 100 // Maximum length of a word
#define MAX_MESSAGE_SIZE 1024

volatile sig_atomic_t reload_flag = 0;
char* global_filename = NULL;

typedef struct {
    char *method;
    char *path;
    char *host;
    int port;
    bool format;
} HttpRequest;

bool is_validIP(char* ip_addr){
    if(ip_addr == NULL){
        return false;
    }
    int num, periods = 0;
    char *token = strtok(ip_addr, ".");
    while(token!=NULL){
        for (int i = 0; token[i] != '\0'; i++) {
            if (!isdigit(token[i])) {
                return false;
            }
        }
        num = atoi(token);
        if(num<0||num>255){
            return false;
        }
        token = strtok(NULL,".");
        if(token!=NULL){
            periods++;
        }
    }
    return periods == 3;
}

char** readWordsFromFile(char* filename) {
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Error opening file %s\n", filename);
        return NULL;
    }

    char** words = (char**)malloc(sizeof(char*)); // Initial allocation for words
    if (words == NULL) {
        fclose(file);
        fprintf(stderr, "Memory allocation failed\n");
        return NULL;
    }

    char buffer[MAX_WORD_LENGTH];
    int i = 0;
    while (fgets(buffer, MAX_WORD_LENGTH, file) != NULL) {
        size_t length = strlen(buffer);
        if (buffer[length - 1] == '\n') {
            buffer[length - 1] = '\0';
            length--; // Update length to exclude newline character
        }

        // Allocate memory for the word, plus one for the null terminator
        words[i] = (char*)malloc(length + 1);
        if (words[i] == NULL) {
            fclose(file);
            fprintf(stderr, "Memory allocation failed\n");
            for (int j = 0; j < i; j++) {
                free(words[j]);
            }
            free(words);
            return NULL;
        }

        // Copy the buffer into the newly allocated space
        strncpy(words[i], buffer, length + 1); // Ensure null-termination

        // Resize the array for the next word, i + 2 because we need an extra spot for the NULL terminator for the array of strings.
        char **tempWords = (char**)realloc(words, (i + 2) * sizeof(char*));
        if (tempWords == NULL) {
            fclose(file);
            fprintf(stderr, "Memory allocation failed\n");
            for (int j = 0; j <= i; j++) { // Free all allocated memory
                free(words[j]);
            }
            free(words); // Free the array of pointers
            return NULL;
        }
        words = tempWords;
        i++;
    }

    // Null-terminate the list of words
    words[i] = NULL;

    fclose(file);
    return words;
}

// Check if the string has a port
int has_port(char* ip_addr){
    char *colon = strchr(ip_addr, ':');
    if (colon == NULL){
        return false;
    }
    return true;
}

char* get_timestamp() {
    struct timeval tv;
    struct tm *tm_info;
    static char buffer[40]; // Ensure buffer is large enough for the full timestamp

    gettimeofday(&tv, NULL); // Get current time with microseconds precision
    tm_info = gmtime(&tv.tv_sec); // Convert seconds to tm structure
    strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%S", tm_info); // Format the date and time
    sprintf(buffer + strlen(buffer), ".%03ldZ", tv.tv_usec / 1000); // Append milliseconds and 'Z'

    return buffer;
}

// This will parse arguments and store in struct values if there is a colon present
int parseInputStringWithColon(char* inputString) {
    HttpRequest* result = (HttpRequest*)malloc(sizeof(HttpRequest));
    int port = 443;  // Initialize port with -1 to indicate no port is specified

    // Check and skip the scheme part if present
    char* urlStart = inputString;
    if (strncmp(inputString, "http://", 7) == 0) {
        urlStart += 7; // Skip "http://"
    }

    // Attempt to parse the remaining URL for both path and port
    int matched = sscanf(urlStart, "%m[^:]:%d", &result->path, &port);
    //printf("%d\n", port);
    if (matched < 1) { // If not even a path is matched
        fprintf(stderr, "Invalid input format.\n");
    }

    if (port != -1 && (port <= 0 || port > 65535)) {
        fprintf(stderr, "Invalid port.\n");
    }

    return port;
}

void freeParsings(HttpRequest* parsedValues) {
    free(parsedValues->method);
    free(parsedValues->path);
    free(parsedValues->host);
}

void init_openssl() { 
    SSL_load_error_strings();   
    OpenSSL_add_ssl_algorithms();
}

void cleanup_openssl() {
    EVP_cleanup();
}

SSL_CTX *create_context() {
    const SSL_METHOD *method;
    SSL_CTX *ctx;

    method = TLS_client_method();

    ctx = SSL_CTX_new(method);
    if (!ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    return ctx;
}

HttpRequest* parse_http_request(const char *request) {
    HttpRequest *http_request = (HttpRequest *)malloc(sizeof(HttpRequest));
    if (http_request == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL;
    }

    // Find the end of the headers (empty line)
    const char *end_of_headers = strstr(request, "\r\n\r\n");
    if (end_of_headers == NULL) {
        fprintf(stderr, "Invalid HTTP request format: missing end of headers.\n");
        free(http_request);
        return NULL;
    }

    // Extract method and path
    char *method_end = strchr(request, ' ');
    if (method_end == NULL) {
        fprintf(stderr, "Invalid HTTP request format: missing method.\n");
        free(http_request);
        return NULL;
    }
    size_t method_len = method_end - request;
    http_request->method = (char *)malloc(method_len + 1);
    if (http_request->method == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        free(http_request);
        return NULL;
    }
    strncpy(http_request->method, request, method_len);
    http_request->method[method_len] = '\0';

    char *path_start = method_end + 1;
    char *path_end = strchr(path_start, ' ');
    if (path_end == NULL) {
        fprintf(stderr, "Invalid HTTP request format: missing path.\n");
        free(http_request->method);
        free(http_request);
        return NULL;
    }
    size_t path_len = path_end - path_start;
    http_request->path = (char *)malloc(path_len + 1);
    if (http_request->path == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        free(http_request->method);
        free(http_request);
        return NULL;
    }
    strncpy(http_request->path, path_start, path_len);
    http_request->path[path_len] = '\0';

    // Extract Host header
    const char *host_start = strstr(request, "Host: ");
    if (host_start == NULL) {
        fprintf(stderr, "Invalid HTTP request format: missing Host header.\n");
        free(http_request->method);
        free(http_request->path);
        free(http_request);
        return NULL;
    }
    host_start += 6; // Move past "Host: "
    const char *host_end = strchr(host_start, '\r');
    if (host_end == NULL) {
        fprintf(stderr, "Invalid HTTP request format: Host header not terminated correctly.\n");
        free(http_request->method);
        free(http_request->path);
        free(http_request);
        return NULL;
    }
    size_t host_len = host_end - host_start;
    http_request->host = (char *)malloc(host_len + 1);
    if (http_request->host == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        free(http_request->method);
        free(http_request->path);
        free(http_request);
        return NULL;
    }
    strncpy(http_request->host, host_start, host_len);
    http_request->host[host_len] = '\0';

    return http_request;
}

// Function to log the request details
void log_request( char* logfile, char* client_ip,  char* request_line, int status_code, size_t response_size) {
    //printf("opening %s\n", logfile);
    FILE* file = fopen(logfile, "a"); // Open the log file in append mode
    if (!file) {
        perror("Failed to open log file");
        return;
    }
    //printf("here\n");
    fprintf(file, "%s %s \"%s\" %d %zu\n", get_timestamp(), client_ip, request_line, status_code, response_size);
    fclose(file); // Close the file after writing the log
}

void forward_chunked_response(BIO* bio, int client_sock) {
    char buffer[BUFFER_SIZE];
    int n;
    char *endptr;
    long chunk_size = 1; // Start with non-zero to enter the loop

    while (chunk_size > 0) {
        n = BIO_gets(bio, buffer, BUFFER_SIZE); // Read the chunk size line
        if (n <= 0) break; // Handle read error or disconnect

        chunk_size = strtol(buffer, &endptr, 16); // Convert chunk size from hex to decimal
        if (chunk_size < 0) break; // Handle conversion error

        while (chunk_size > 0) {
            n = BIO_read(bio, buffer, (chunk_size < BUFFER_SIZE) ? chunk_size : BUFFER_SIZE - 1);
            if (n <= 0) break; // Handle read error or disconnect
            
            send(client_sock, buffer, n, 0); // Forward chunk to client
            chunk_size -= n; // Decrease remaining chunk size
        }

        BIO_read(bio, buffer, 2); // Read and discard the CRLF after the chunk
    }
}

void handle_client(int client_sock, char* filename, char* logfile, char** words) {
    char buffer[BUFFER_SIZE] = {0};
    ssize_t bytes_received = recv(client_sock, buffer, BUFFER_SIZE - 1, 0);
    if (bytes_received < 0) {
        perror("recv failed");
        return;
    }

    //printf("Received request: %s\n", buffer);
    HttpRequest* req = parse_http_request(buffer);
    req->port = parseInputStringWithColon(req->path);
    //printf("\n\nMethod: %s\nPath: %s\nHost: %s\nPort: %d\n", req->method, req->path, req->host, req->port);

    init_openssl();
    SSL_CTX* ctx = create_context();
    SSL* ssl;

    BIO* bio = BIO_new_ssl_connect(ctx);
    BIO_get_ssl(bio, &ssl);
    SSL_set_mode(ssl, SSL_MODE_AUTO_RETRY);

    char target_address[BUFFER_SIZE] = {0};
    sprintf(target_address, "%s:%d", req->host, req->port);
    BIO_set_conn_hostname(bio, target_address);
    printf("Connecting to %s\n", target_address);

    if (BIO_do_connect(bio) <= 0) {
        fprintf(stderr, "Error attempting to connect\n");
        ERR_print_errors_fp(stderr);
        BIO_free_all(bio);
        SSL_CTX_free(ctx);
        return;
    }

    // Check for forbidden hosts
    bool forbidden = false;
    // Assuming readWordsFromFile and other utility functions are implemented elsewhere
    
    for (int i = 0; words[i] != NULL; i++) {
        if(strcmp(req->host, words[i]) == 0){
            forbidden = true;
            break;
        }
        free(words[i]);
    }
    free(words); // Assuming words is NULL terminated and dynamically allocated

    int total_response_size = 0;
    int status_code = 200;
    char request_line[256];
    if (forbidden) {
        char* message = "HTTP/1.1 403 Forbidden\r\n"
                        "Content-Type: text/plain\r\n"
                        "Content-Length: 13\r\n"
                        "\r\n"
                        "403 Forbidden";
        status_code = 403;
        total_response_size = strlen(message);
        snprintf(request_line, sizeof(request_line), "%s %s %s", req->method, req->path, "HTTP/1.1");
        log_request(logfile, req->host, request_line, status_code, total_response_size);
        send(client_sock, message, strlen(message), 0);
    } else if (strcmp(req->method, "GET") != 0 && strcmp(req->method, "HEAD") != 0) {
        char* message = "HTTP/1.1 501 Not Implemented\r\n"
                        "Content-Type: text/plain\r\n"
                        "Content-Length: 17\r\n"
                        "\r\n"
                        "501 Not Implemented";
        status_code = 501;
        total_response_size = strlen(message);
        snprintf(request_line, sizeof(request_line), "%s %s %s", req->method, req->path, "HTTP/1.1");
        log_request(logfile, req->host, request_line, status_code, total_response_size);
        send(client_sock, message, strlen(message), 0);
    } else {
        char message[MAX_MESSAGE_SIZE];
        snprintf(message, MAX_MESSAGE_SIZE,
                 "%s %s HTTP/1.1\r\n"
                 "Host: %s\r\n\r\n",
                 req->method, req->path, req->host);
        
        snprintf(request_line, sizeof(request_line), "%s %s %s", req->method, req->path, "HTTP/1.1");
        BIO_write(bio, message, strlen(message));
        
        // Modified part to handle chunked encoding
        int is_chunked = 0;
        char header_buffer[BUFFER_SIZE] = {0};
        while (BIO_gets(bio, header_buffer, BUFFER_SIZE - 1) > 0) {
            if(strcmp(header_buffer, "\r\n") == 0) break; // End of headers
            if(strstr(header_buffer, "Transfer-Encoding: chunked")) is_chunked = 1;
        }

        if (is_chunked) {
            forward_chunked_response(bio, client_sock);
            log_request(logfile, req->host, request_line, status_code, total_response_size);
        } else {
            // Non-chunked handling
            int len = 0;
            do {
                len = BIO_read(bio, buffer, BUFFER_SIZE - 1);
                if (len > 0) {
                    sscanf(buffer, "HTTP/%*s %d", &status_code);
                    total_response_size += len; // Accumulate total response size
                    log_request(logfile, req->host, request_line, status_code, total_response_size);
                    send(client_sock, buffer, len, 0); // Send data to client
                }
            } while (len > 0 || BIO_should_retry(bio));
        }
    }

    BIO_free_all(bio);
    SSL_CTX_free(ctx);
    cleanup_openssl();
}


bool valid_port(char* port){
    for (int i = 0; port[i] != '\0'; i++) {
        if (!isdigit(port[i])) {
            return false;
        }
    }

    if (atoi(port) <= 1 || atoi(port) >= 65535){
        return false;
    }
    return true;
}

void sigint_handler(int sig_num) {
    printf("\nSIGINT received. Flagging for file reload...\n");
    reload_flag = 1;
}

int main(int argc, char **argv) {

    if(!(argc==3 || argc==4)){
        fprintf(stdout, "Invalid number of arguments.\n");
        return 1;
    }
    
    int LISTEN_PORT = 443;
    if(argc==4){
        if(valid_port(argv[1])){
            LISTEN_PORT = atoi(argv[1]);
        }else{
            fprintf(stdout, "Invalid port.\n");
            return 1;
        }
    }


        /***This is to handle requests***/
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    pid_t childpid;

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(LISTEN_PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    //Signal(SIGCHLD, sig_chld);

    printf("Listening on port %d...\n", LISTEN_PORT);
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigint_handler;
    sigaction(SIGINT, &sa, NULL);
    global_filename = argv[2];

    while(1) {
        char** new_data = readWordsFromFile(global_filename);
        if (reload_flag) {
            printf("Reloading file '%s'...\n", global_filename);
            
            new_data = readWordsFromFile(global_filename);
            

            reload_flag = 0; // Reset the flag after reloading
        }
        new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen);

        if (new_socket < 0) {
            if (errno == EINTR) {
                printf("accept was interrupted by SIGINT. Checking for reload or other actions.\n");
                continue; // If intending to keep the server running, continue to the next iteration
            } else {
                perror("accept");
                continue; // Optionally handle other accept errors or break/exit
            }
        }
        if ((childpid = fork()) == 0) { /* child process */
            close(server_fd); /* close listening socket */
            handle_client(new_socket, global_filename, argv[3], new_data); /* process the request */
            close(new_socket);
            exit(0);
        }
        close(new_socket);
    }

    return 0;
}
