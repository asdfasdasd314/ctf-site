<script lang="ts">
    import { onMount } from 'svelte';
    import "../app.css";
    
    interface ProductImage {
      id: number;
      src: string;
      alt: string;
    }
    
    // Product data
    const product = {
      name: "Premium Comfort T-Shirt",
      price: 29.99,
      description: "Our signature t-shirt combines style and comfort with premium organic cotton. Perfect for everyday wear with a relaxed fit and reinforced stitching for durability.",
      features: [
        "100% Organic Cotton",
        "Relaxed Fit",
        "Machine Washable",
        "Available in 5 colors"
      ],
      images: [
        { id: 1, src: "/placeholder.svg?height=600&width=500", alt: "T-shirt front view" },
        { id: 2, src: "/placeholder.svg?height=600&width=500", alt: "T-shirt back view" },
        { id: 3, src: "/placeholder.svg?height=600&width=500", alt: "T-shirt side view" }
      ]
    };
    
    // Reviews data
    const reviews = [
      { id: 1, author: "Alex M.", rating: 5, text: "Absolutely love this shirt! The fabric is so soft and comfortable, and it fits perfectly. Will definitely buy more colors." },
      { id: 2, author: "Jamie L.", rating: 4, text: "Great quality t-shirt that has held up well after multiple washes. The fit is slightly larger than expected, but still looks good." },
      { id: 3, author: "Taylor S.", rating: 5, text: "This is my go-to t-shirt now. The material feels premium and breathable. Worth every penny!" }
    ];
    
    // State
    let selectedImage = product.images[0];
    let quantity = 1;
    let promoCode = "";
    
    // Methods
    function selectImage(image: ProductImage) {
      selectedImage = image;
    }
    
    function incrementQuantity() {
      quantity++;
    }
    
    function decrementQuantity() {
      if (quantity > 1) quantity--;
    }
    
    function renderStars(rating: number) {
      return Array(5)
        .fill(0)
        .map((_, i) => i < rating ? "★" : "☆")
        .join("");
    }
  </script>
  
  <div class="min-h-screen bg-gray-50">
    <!-- Navbar -->
    <nav class="bg-white shadow-md">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <span class="text-xl font-bold text-gray-900">Coupons.com</span>
          </div>
          <div class="hidden md:flex items-center space-x-8">
            <a href="#" class="text-gray-600 hover:text-gray-900">Home</a>
            <a href="#" class="text-gray-600 hover:text-gray-900">Shop</a>
            <a href="#" class="text-gray-600 hover:text-gray-900">Categories</a>
            <a href="#" class="text-gray-600 hover:text-gray-900">About</a>
          </div>
          <div class="flex items-center space-x-4">
            <button class="text-gray-600 hover:text-gray-900" aria-label="Shopping Cart">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
              </svg>
            </button>
            <button class="text-gray-600 hover:text-gray-900" aria-label="User Account">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </nav>
    
    <!-- Product Section -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <!-- Product Images -->
        <div class="flex flex-col">
          <!-- Main Image -->
          <div class="mb-4 border rounded-lg overflow-hidden bg-white p-4">
            <img src={selectedImage.src || "/placeholder.svg"} alt={selectedImage.alt} class="w-full h-auto object-contain" style="height: 400px;" />
          </div>
          
          <!-- Thumbnail Images -->
          <div class="flex space-x-4 overflow-x-auto pb-2">
            {#each product.images as image}
              <button 
                class="border rounded-md overflow-hidden flex-shrink-0 {selectedImage.id === image.id ? 'ring-2 ring-offset-2 ring-rose-500' : ''}" 
                on:click={() => selectImage(image)}
              >
                <img src={image.src || "/placeholder.svg"} alt={image.alt} class="w-20 h-20 object-cover" />
              </button>
            {/each}
          </div>
        </div>
        
        <!-- Product Info -->
        <div class="flex flex-col">
          <h1 class="text-3xl font-bold text-gray-900">{product.name}</h1>
          <div class="mt-2">
            <span class="text-2xl font-semibold text-gray-900">${product.price}</span>
          </div>
          
          <div class="mt-6">
            <h2 class="text-lg font-medium text-gray-900">Info</h2>
            <div class="mt-2 text-gray-600">
              <p>{product.description}</p>
              <ul class="list-disc list-inside mt-4 space-y-1">
                {#each product.features as feature}
                  <li>{feature}</li>
                {/each}
              </ul>
            </div>
          </div>
          
          <div class="mt-6">
            <div class="flex items-center">
              <span class="mr-3 text-gray-700">Quantity</span>
              <div class="flex items-center border rounded-md">
                <button 
                  class="px-3 py-1 text-gray-600 hover:bg-gray-100" 
                  on:click={decrementQuantity}
                >
                  -
                </button>
                <span class="px-4 py-1 text-gray-900">{quantity}</span>
                <button 
                  class="px-3 py-1 text-gray-600 hover:bg-gray-100" 
                  on:click={incrementQuantity}
                >
                  +
                </button>
              </div>
            </div>
          </div>
          
          <div class="mt-6">
            <label for="promo-code" class="block text-sm font-medium text-gray-700">Promo Code</label>
            <div class="mt-1">
              <input
                type="text"
                id="promo-code"
                bind:value={promoCode}
                class="shadow-sm focus:ring-rose-500 focus:border-rose-500 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
                placeholder="Enter promo code"
              />
            </div>
          </div>
          
          <div class="mt-6">
            <button class="w-full bg-rose-600 border border-transparent rounded-md py-3 px-8 flex items-center justify-center text-base font-medium text-white hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-rose-500">
              Add to Cart
            </button>
          </div>
        </div>
      </div>
      
      <!-- Reviews Section -->
      <div class="mt-16">
        <h2 class="text-2xl font-bold text-gray-900">Reviews</h2>
        <div class="mt-6 space-y-6">
          {#each reviews as review}
            <div class="border-b border-gray-200 pb-6">
              <div class="flex items-center">
                <p class="font-medium text-gray-900">{review.author}</p>
                <div class="ml-4 text-yellow-400">
                  {renderStars(review.rating)}
                </div>
              </div>
              <div class="mt-2 text-gray-600">
                <p>{review.text}</p>
              </div>
            </div>
          {/each}
        </div>
      </div>
    </div>
  </div>