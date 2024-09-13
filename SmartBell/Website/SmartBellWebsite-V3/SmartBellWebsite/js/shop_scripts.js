let cart = localStorage.getItem('cart') ? JSON.parse(localStorage.getItem('cart')) : [];

// Function to add an item to the cart
function addToCart(productName, price) {
  const existingItem = cart.find(item => item.productName === productName);

  if (existingItem) {
    existingItem.quantity++;
  } else {
    cart.push({ productName, price, quantity: 1 });
  }

  updateCartInfo();
  saveCartToStorage();
}

// Function to update cart information
function updateCartInfo() {
  const cartCountElement = document.getElementById('cartCount');
  const cartTotalElement = document.getElementById('cartTotal');

  if (!cartCountElement || !cartTotalElement) {
    console.error('Error: One or more cart elements not found');
    return;
  }

  const itemCount = cart.reduce((total, item) => total + (item.quantity || 0), 0);
  const totalAmount = cart.reduce((total, item) => total + (item.price || 0) * (item.quantity || 0), 0);

  if (isNaN(itemCount) || isNaN(totalAmount)) {
    console.error('Error: NaN found in itemCount or totalAmount');
    return;
  }

  cartCountElement.textContent = 'Items in cart: ' + itemCount;
  cartTotalElement.textContent = 'Total Cost: $' + totalAmount.toFixed(2);
}

// Function to save the cart to storage
function saveCartToStorage() {
  localStorage.setItem('cart', JSON.stringify(cart));
}

// Function to display cart summary in shop.html
function displayCartSummary() {
  const cartCountElement = document.getElementById('cartCount');
  const cartTotalElement = document.getElementById('cartTotal');

  if (!cartCountElement || !cartTotalElement) {
    console.error('Error: One or more cart elements not found');
    return;
  }

  const itemCount = cart.reduce((total, item) => total + (item.quantity || 0), 0);
  const totalAmount = cart.reduce((total, item) => total + (item.price || 0) * (item.quantity || 0), 0);

  if (isNaN(itemCount) || isNaN(totalAmount)) {
    console.error('Error: NaN found in itemCount or totalAmount');
    return;
  }

  cartCountElement.textContent = itemCount + ' items';
  cartTotalElement.textContent = '$' + totalAmount.toFixed(2);
}

// Load cart from storage on page load
document.addEventListener('DOMContentLoaded', function () {
  updateCartInfo();
  displayCartSummary();
});

// Update cart info when the user navigates back to the shop page
window.addEventListener('pageshow', function (event) {
  if (event.persisted || (window.performance && window.performance.navigation.type == 2)) {
    // Page is being restored from cache, update cart info
    updateCartInfo();
    displayCartSummary();
  }
});

// Function to add an item to the cart and update cart summary
function addToCartButtonClick(productName, price) {
  addToCart(productName, price);
  displayCartSummary();
}

// Function to continue shopping
function continueShopping() {
  window.location.href = 'shop.html';
}

// Function to display cart items with quantities
function displayCartItemsWithQuantities() {
  const cartItemsQuantitiesElement = document.getElementById('cartItemsQuantities');

  if (!cartItemsQuantitiesElement) {
    console.error('Error: cartItemsQuantities element not found');
    return;
  }

  cartItemsQuantitiesElement.innerHTML = '';

  for (let i = 0; i < cart.length; i++) {
    const item = cart[i];

    const quantityInput = document.createElement('input');
    quantityInput.type = 'number';
    quantityInput.value = item.quantity;
    quantityInput.min = 1;
    quantityInput.className = 'quantity-input';
    quantityInput.addEventListener('change', (event) => updateQuantity(i, event.target.value));

    cartItemsQuantitiesElement.appendChild(quantityInput);
  }
}

// Function to update the quantity of an item
function updateQuantity(index, newQuantity) {
  cart[index].quantity = parseInt(newQuantity);

  updateCartInfo();
  saveCartToStorage();

  displayCartItemsWithQuantities();
}

// Function to update quantities
function updateQuantities() {
  updateCartInfo();
  saveCartToStorage();

  displayCartItemsWithQuantities();
}

// Function to delete an item from the cart
function deleteItem(index) {
  cart.splice(index, 1);

  updateCartInfo();
  saveCartToStorage();

  displayCartItems();
}

// Function to delete one item from the cart
function deleteOneItem(index) {
  if (cart[index].quantity > 1) {
    cart[index].quantity--;
  } else {
    cart.splice(index, 1);
  }

  updateCartInfo();
  saveCartToStorage();

  displayCartItems();
}

// Function to display cart items on page load
function displayCartItems() {
  const cartItemsElement = document.getElementById('cartItems');
  const cartTotalElement = document.getElementById('cartTotal');

  if (!cartItemsElement || !cartTotalElement) {
    console.error('Error: cartItems or cartTotal element not found');
    return;
  }

  cartItemsElement.innerHTML = '';

  for (let i = 0; i < cart.length; i++) {
    const item = cart[i];

    const itemElement = document.createElement('div');

    const quantityInput = document.createElement('input');
    quantityInput.type = 'number';
    quantityInput.value = item.quantity;
    quantityInput.min = '1';
    quantityInput.addEventListener('input', (event) => updateQuantity(i, event.target.value));

    const quantityTextNode = document.createTextNode(` x ${item.productName} - $${(item.price * item.quantity).toFixed(2)}`);

    const deleteButton = document.createElement('button');
    deleteButton.innerText = 'Delete';
    deleteButton.addEventListener('click', () => deleteOneItem(i));

    itemElement.appendChild(quantityInput);
    itemElement.appendChild(quantityTextNode);
    itemElement.appendChild(deleteButton);

    cartItemsElement.appendChild(itemElement);
  }

  const totalAmount = cart.reduce((total, item) => total + (item.price || 0) * (item.quantity || 0), 0);
  cartTotalElement.textContent = '$' + totalAmount.toFixed(2);
}

// Call the function to display cart items on page load
displayCartItems();


function displayCartItems() {
  const cartItemsElement = document.getElementById('cartItems');
  const cartTotalElement = document.getElementById('cartTotal');

  // Check if the cartItems element is present
  if (!cartItemsElement || !cartTotalElement) {
    console.error('Error: cartItems or cartTotal element not found');
    return;
  }

  // Clear existing content
  cartItemsElement.innerHTML = '';

  // Iterate through the cart items and create elements for display
  for (let i = 0; i < cart.length; i++) {
    const item = cart[i];

    const itemElement = document.createElement('div');

    // Create input element for quantity
    const quantityInput = document.createElement('input');
    quantityInput.type = 'number';
    quantityInput.value = item.quantity;
    quantityInput.min = '1';
    quantityInput.addEventListener('input', (event) => updateQuantity(i, event.target.value));

    // Create a text node for displaying the quantity
    const quantityTextNode = document.createTextNode(` x ${item.productName} - $${(item.price * item.quantity).toFixed(2)}`);

    // Add a delete button for each item
    const deleteButton = document.createElement('button');
    deleteButton.innerText = 'Delete';
    deleteButton.addEventListener('click', () => deleteOneItem(i));

    // Append the quantity input, text node, and delete button to the itemElement
    itemElement.appendChild(quantityInput);
    itemElement.appendChild(quantityTextNode);
    itemElement.appendChild(deleteButton);

    // Append the itemElement to the cartItemsElement
    cartItemsElement.appendChild(itemElement);
  }

  // Display total cost
  const totalAmount = cart.reduce((total, item) => total + (item.price || 0) * (item.quantity || 0), 0);
  cartTotalElement.textContent = '$' + totalAmount.toFixed(2);
}


// Function to delete an item from the cart
function deleteItem(index) {
  // Remove the item from the cart array
  cart.splice(index, 1);

  // Update cart information and save to storage
  updateCartInfo();
  saveCartToStorage();

  // Redisplay cart items
  displayCartItems();
}

function saveCartToStorage() {
  // Save the cart to local storage
  localStorage.setItem('cart', JSON.stringify(cart));
}

// Load cart from storage on page load
updateCartInfo();

document.addEventListener('DOMContentLoaded', function () {
  updateCartInfo();
});

// Update cart info when the user navigates back to the shop page
window.addEventListener('pageshow', function (event) {
  if (event.persisted || (window.performance && window.performance.navigation.type == 2)) {
    // Page is being restored from cache, update cart info
    updateCartInfo();
  }
});

// Function to continue shopping
function continueShopping() {
  // Redirect to your main shop page
  window.location.href = 'shop.html';
}

// Function to display cart items with quantities
function displayCartItemsWithQuantities() {
  const cartItemsQuantitiesElement = document.getElementById('cartItemsQuantities');

  if (!cartItemsQuantitiesElement) {
    console.error('Error: cartItemsQuantities element not found');
    return;
  }

  // Clear existing content
  cartItemsQuantitiesElement.innerHTML = '';

  // Iterate through the cart items and create elements for display
  for (let i = 0; i < cart.length; i++) {
    const item = cart[i];

    // Create input for quantity
    const quantityInput = document.createElement('input');
    quantityInput.type = 'number';
    quantityInput.value = item.quantity;
    quantityInput.min = 1;
    quantityInput.className = 'quantity-input'; 
    quantityInput.addEventListener('change', (event) => updateQuantity(i, event.target.value));

    cartItemsQuantitiesElement.appendChild(quantityInput);
  }
}

// Function to update the quantity of an item
function updateQuantity(index, newQuantity) {
  // Update the quantity of the item in the cart
  cart[index].quantity = parseInt(newQuantity);

  // Update cart information and save to storage
  updateCartInfo();
  saveCartToStorage();

  // Redisplay cart items with quantities
  displayCartItemsWithQuantities();
}

// Function to update quantities
function updateQuantities() {
  // Update cart information and save to storage
  updateCartInfo();
  saveCartToStorage();

  // Redisplay cart items with quantities
  displayCartItemsWithQuantities();
}

function displayCartSummary() {
  const cartCountElement = document.getElementById('cartCount');
  const cartTotalElement = document.getElementById('cartTotal');

  if (!cartCountElement || !cartTotalElement) {
    console.error('Error: One or more cart elements not found');
    return;
  }

  const itemCount = cart.reduce((total, item) => total + (item.quantity || 0), 0);
  const totalAmount = cart.reduce((total, item) => total + (item.price || 0) * (item.quantity || 0), 0);

  if (isNaN(itemCount) || isNaN(totalAmount)) {
    console.error('Error: NaN found in itemCount or totalAmount');
    return;
  }

  cartCountElement.textContent = 'Items in cart: ' + itemCount;
  cartTotalElement.textContent = 'Total cost: $' + totalAmount.toFixed(2);
}

// Call the function to display cart summary on page load
document.addEventListener('DOMContentLoaded', function () {
  displayCartSummary();
});

// Update cart info when the user navigates back to the shop page
window.addEventListener('pageshow', function (event) {
  if (event.persisted || (window.performance && window.performance.navigation.type == 2)) {
    // Page is being restored from cache, update cart summary
    displayCartSummary();
  }
});