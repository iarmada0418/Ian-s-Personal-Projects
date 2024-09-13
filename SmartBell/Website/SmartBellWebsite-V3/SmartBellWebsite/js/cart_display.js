// cart_display.js

document.addEventListener('DOMContentLoaded', function () {
    displayCartItems();
  });
  
  function displayCartItems() {
    let cartItemsContainer = document.getElementById('cartItems');
    let cartItems = getCartItems();
  
    if (cartItems.length === 0) {
      cartItemsContainer.innerHTML = '<p>Your cart is empty.</p>';
    } else {
      for (let item of cartItems) {
        let cartItemElement = document.createElement('div');
        cartItemElement.innerHTML = `
          <div>
            <img src="${item.image}" alt="${item.productName} Image">
          </div>
          <div>
            <h2>${item.productName}</h2>
            <p>$${item.price.toFixed(2)}</p>
          </div>
        `;
        cartItemsContainer.appendChild(cartItemElement);
      }
    }
  }
  
  function getCartItems() {
    // Retrieve cart items from local storage
    return JSON.parse(localStorage.getItem('cart')) || [];
  }
  