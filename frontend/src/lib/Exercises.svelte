<script lang="ts">
    import { onMount } from 'svelte';
    import { fade, fly } from 'svelte/transition';
    
    // Exercise type definition
    type Difficulty = 'Beginner' | 'Intermediate' | 'Advanced';
    
    interface Exercise {
      id: number;
      title: string;
      description: string;
      difficulty: Difficulty;
      category: string;
      points: number;
      solveCount?: number;
      isCompleted?: boolean;
      tags?: string[];
      createdAt: string;
    }
    
    // Filter state
    let searchQuery = '';
    let selectedCategory = 'All';
    let selectedDifficulty = 'All';
    let sortBy = 'newest';
    
    // UI state
    let isLoading = true;
    let viewMode: 'grid' | 'list' = 'grid';
    
    // Sample categories - replace with your actual categories
    const categories = [
      'All',
      'Web',
      'Crypto',
      'Binary',
      'Forensics',
      'Reverse',
      'OSINT',
      'Network',
      'Misc'
    ];
    
    // Sample difficulties
    const difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
    
    // Sample exercises data - replace with your actual exercises
    let allExercises: Exercise[] = [
      {
        id: 1,
        title: 'SQL Injection Basics',
        description: 'Learn how to exploit SQL injection vulnerabilities in web applications.',
        difficulty: 'Beginner',
        category: 'Web',
        points: 100,
        solveCount: 243,
        isCompleted: false,
        tags: ['sql', 'injection', 'web-security'],
        createdAt: '2023-09-15'
      },
      {
        id: 2,
        title: 'Caesar Cipher Cracking',
        description: 'Break the classic Caesar cipher encryption and recover the hidden message.',
        difficulty: 'Beginner',
        category: 'Crypto',
        points: 75,
        solveCount: 312,
        isCompleted: true,
        tags: ['cryptography', 'classical-ciphers'],
        createdAt: '2023-08-22'
      },
      {
        id: 3,
        title: 'Buffer Overflow Exploitation',
        description: 'Exploit a buffer overflow vulnerability to gain control of program execution.',
        difficulty: 'Advanced',
        category: 'Binary',
        points: 300,
        solveCount: 87,
        isCompleted: false,
        tags: ['buffer-overflow', 'exploitation', 'memory-corruption'],
        createdAt: '2023-10-05'
      },
      {
        id: 4,
        title: 'Network Packet Analysis',
        description: 'Analyze network traffic to identify suspicious activities and extract hidden data.',
        difficulty: 'Intermediate',
        category: 'Network',
        points: 150,
        solveCount: 156,
        isCompleted: false,
        tags: ['wireshark', 'pcap', 'network-analysis'],
        createdAt: '2023-09-28'
      },
      {
        id: 5,
        title: 'Steganography Challenge',
        description: 'Extract hidden information from images using steganography techniques.',
        difficulty: 'Intermediate',
        category: 'Forensics',
        points: 200,
        solveCount: 132,
        isCompleted: false,
        tags: ['steganography', 'image-analysis', 'hidden-data'],
        createdAt: '2023-07-14'
      },
      {
        id: 6,
        title: 'Reverse Engineering a Mobile App',
        description: 'Decompile and analyze an Android application to find vulnerabilities.',
        difficulty: 'Advanced',
        category: 'Reverse',
        points: 350,
        solveCount: 64,
        isCompleted: false,
        tags: ['android', 'decompilation', 'mobile-security'],
        createdAt: '2023-10-12'
      },
      {
        id: 7,
        title: 'Cross-Site Scripting (XSS)',
        description: 'Identify and exploit XSS vulnerabilities in a web application.',
        difficulty: 'Beginner',
        category: 'Web',
        points: 125,
        solveCount: 198,
        isCompleted: false,
        tags: ['xss', 'javascript', 'web-security'],
        createdAt: '2023-08-30'
      },
      {
        id: 8,
        title: 'Command Injection',
        description: 'Exploit command injection vulnerabilities to execute arbitrary commands.',
        difficulty: 'Intermediate',
        category: 'Web',
        points: 175,
        solveCount: 143,
        isCompleted: false,
        tags: ['command-injection', 'web-security'],
        createdAt: '2023-09-10'
      },
      {
        id: 9,
        title: 'RSA Encryption Challenge',
        description: 'Break weak RSA encryption implementations to recover the private key.',
        difficulty: 'Advanced',
        category: 'Crypto',
        points: 275,
        solveCount: 92,
        isCompleted: false,
        tags: ['rsa', 'cryptography', 'math'],
        createdAt: '2023-07-25'
      },
      {
        id: 10,
        title: 'Memory Forensics',
        description: 'Analyze memory dumps to identify malicious processes and artifacts.',
        difficulty: 'Advanced',
        category: 'Forensics',
        points: 325,
        solveCount: 78,
        isCompleted: false,
        tags: ['memory-analysis', 'volatility', 'forensics'],
        createdAt: '2023-10-01'
      },
      {
        id: 11,
        title: 'Social Engineering OSINT',
        description: 'Use open-source intelligence to gather information about a target.',
        difficulty: 'Beginner',
        category: 'OSINT',
        points: 100,
        solveCount: 221,
        isCompleted: false,
        tags: ['osint', 'reconnaissance', 'information-gathering'],
        createdAt: '2023-08-15'
      },
      {
        id: 12,
        title: 'Firmware Analysis',
        description: 'Extract and analyze IoT device firmware to identify security issues.',
        difficulty: 'Advanced',
        category: 'Reverse',
        points: 400,
        solveCount: 45,
        isCompleted: false,
        tags: ['iot', 'firmware', 'embedded'],
        createdAt: '2023-09-20'
      }
    ];
    
    // Filtered exercises based on search and filters
    $: filteredExercises = allExercises.filter(exercise => {
      // Search query filter
      const matchesSearch = searchQuery === '' || 
        exercise.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        exercise.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (exercise.tags && exercise.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase())));
      
      // Category filter
      const matchesCategory = selectedCategory === 'All' || exercise.category === selectedCategory;
      
      // Difficulty filter
      const matchesDifficulty = selectedDifficulty === 'All' || exercise.difficulty === selectedDifficulty;
      
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).sort((a, b) => {
      // Sorting logic
      switch (sortBy) {
        case 'newest':
          return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        case 'oldest':
          return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        case 'points-high':
          return b.points - a.points;
        case 'points-low':
          return a.points - b.points;
        case 'popularity':
          return (b.solveCount || 0) - (a.solveCount || 0);
        default:
          return 0;
      }
    });
    
    // Pagination
    let currentPage = 1;
    let itemsPerPage = 8;
    $: totalPages = Math.ceil(filteredExercises.length / itemsPerPage);
    $: paginatedExercises = filteredExercises.slice(
      (currentPage - 1) * itemsPerPage,
      currentPage * itemsPerPage
    );
    
    function changePage(page: number) {
      if (page >= 1 && page <= totalPages) {
        currentPage = page;
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    }
    
    function resetFilters() {
      searchQuery = '';
      selectedCategory = 'All';
      selectedDifficulty = 'All';
      sortBy = 'newest';
      currentPage = 1;
    }
    
    // Get difficulty color class
    function getDifficultyColor(difficulty: Difficulty): string {
      switch (difficulty) {
        case 'Beginner':
          return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
        case 'Intermediate':
          return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
        case 'Advanced':
          return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
        default:
          return 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200';
      }
    }
    
    onMount(() => {
      // Simulate loading data
      setTimeout(() => {
        isLoading = false;
      }, 800);
    });
  </script>
  
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 pb-20">
    <!-- Header -->
    <header class="bg-gradient-to-r from-emerald-600 to-cyan-600 py-16 px-4">
      <div class="container mx-auto max-w-6xl">
        <div in:fly={{ y: -20, duration: 800 }}>
          <h1 class="text-4xl md:text-5xl font-bold text-white mb-4">CTF Challenges</h1>
          <p class="text-emerald-100 text-lg md:text-xl max-w-2xl">
            Browse our collection of cybersecurity challenges designed to test and improve your skills. 
            Filter by category, difficulty, or search for specific topics.
          </p>
        </div>
      </div>
    </header>
    
    <!-- Filters Section -->
    <section class="py-8 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 sticky top-0 z-10 shadow-md">
      <div class="container mx-auto max-w-6xl px-4">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <!-- Search -->
          <div class="relative w-full md:w-64">
            <input
              type="text"
              bind:value={searchQuery}
              placeholder="Search challenges..."
              class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
            />
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </div>
          
          <div class="flex flex-wrap gap-2 md:gap-4">
            <!-- Category Filter -->
            <select
              bind:value={selectedCategory}
              class="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
            >
              {#each categories as category}
                <option value={category}>{category}</option>
              {/each}
            </select>
            
            <!-- Difficulty Filter -->
            <select
              bind:value={selectedDifficulty}
              class="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
            >
              {#each difficulties as difficulty}
                <option value={difficulty}>{difficulty}</option>
              {/each}
            </select>
            
            <!-- Sort By -->
            <select
              bind:value={sortBy}
              class="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
            >
              <option value="newest">Newest First</option>
              <option value="oldest">Oldest First</option>
              <option value="points-high">Highest Points</option>
              <option value="points-low">Lowest Points</option>
              <option value="popularity">Most Popular</option>
            </select>
            
            <!-- View Toggle -->
            <div class="flex rounded-lg overflow-hidden border border-gray-300 dark:border-gray-600">
              <button
                class={`px-3 py-2 ${viewMode === 'grid' ? 'bg-emerald-500 text-white' : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200'}`}
                on:click={() => viewMode = 'grid'}
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="3" y="3" width="7" height="7"></rect>
                  <rect x="14" y="3" width="7" height="7"></rect>
                  <rect x="14" y="14" width="7" height="7"></rect>
                  <rect x="3" y="14" width="7" height="7"></rect>
                </svg>
              </button>
              <button
                class={`px-3 py-2 ${viewMode === 'list' ? 'bg-emerald-500 text-white' : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200'}`}
                on:click={() => viewMode = 'list'}
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="8" y1="6" x2="21" y2="6"></line>
                  <line x1="8" y1="12" x2="21" y2="12"></line>
                  <line x1="8" y1="18" x2="21" y2="18"></line>
                  <line x1="3" y1="6" x2="3.01" y2="6"></line>
                  <line x1="3" y1="12" x2="3.01" y2="12"></line>
                  <line x1="3" y1="18" x2="3.01" y2="18"></line>
                </svg>
              </button>
            </div>
            
            <!-- Reset Filters -->
            <button
              on:click={resetFilters}
              class="px-3 py-2 text-emerald-500 hover:text-emerald-600 dark:text-emerald-400 dark:hover:text-emerald-300 font-medium"
            >
              Reset
            </button>
          </div>
        </div>
      </div>
    </section>
    
    <!-- Results Section -->
    <section class="py-12">
      <div class="container mx-auto max-w-6xl px-4">
        <!-- Results Count -->
        <div class="mb-6 flex justify-between items-center">
          <p class="text-gray-700 dark:text-gray-300">
            Showing <span class="font-semibold">{filteredExercises.length}</span> challenges
            {selectedCategory !== 'All' ? `in ${selectedCategory}` : ''}
            {selectedDifficulty !== 'All' ? `with ${selectedDifficulty} difficulty` : ''}
            {searchQuery ? `matching "${searchQuery}"` : ''}
          </p>
        </div>
        
        {#if isLoading}
          <!-- Loading State -->
          <div class="flex justify-center items-center py-20">
            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-emerald-500"></div>
          </div>
        {:else if filteredExercises.length === 0}
          <!-- No Results -->
          <div class="text-center py-20" in:fade={{ duration: 300 }}>
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mx-auto text-gray-400 mb-4">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="8" x2="12" y2="12"></line>
              <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <h3 class="text-xl font-bold mb-2">No challenges found</h3>
            <p class="text-gray-600 dark:text-gray-400 mb-6">Try adjusting your filters or search query</p>
            <button
              on:click={resetFilters}
              class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300"
            >
              Reset Filters
            </button>
          </div>
        {:else}
          <!-- Grid View -->
          {#if viewMode === 'grid'}
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {#each paginatedExercises as exercise, i}
                <div 
                  in:fade={{ delay: 50 * i, duration: 300 }}
                  class="bg-white dark:bg-gray-800 rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden border border-gray-200 dark:border-gray-700 flex flex-col"
                >
                  <!-- Card Header with Category Background -->
                  <div class="h-3 bg-gradient-to-r from-emerald-400 to-cyan-500"></div>
                  
                  <div class="p-6 flex flex-col flex-grow">
                    <!-- Title and Difficulty -->
                    <div class="flex justify-between items-start mb-3">
                      <h3 class="text-lg font-bold line-clamp-2">{exercise.title}</h3>
                      <span class={`text-xs font-medium px-2 py-1 rounded-full ml-2 whitespace-nowrap ${getDifficultyColor(exercise.difficulty)}`}>
                        {exercise.difficulty}
                      </span>
                    </div>
                    
                    <!-- Description -->
                    <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 line-clamp-3">{exercise.description}</p>
                    
                    <!-- Tags -->
                    {#if exercise.tags && exercise.tags.length > 0}
                      <div class="flex flex-wrap gap-1 mb-4">
                        {#each exercise.tags as tag}
                          <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 px-2 py-1 rounded-full">
                            #{tag}
                          </span>
                        {/each}
                      </div>
                    {/if}
                    
                    <!-- Stats -->
                    <div class="flex items-center justify-between mt-auto pt-4 text-sm text-gray-500 dark:text-gray-400">
                      <div class="flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-1">
                          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                        </svg>
                        <span>{exercise.points} pts</span>
                      </div>
                      <div class="flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-1">
                          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                          <circle cx="9" cy="7" r="4"></circle>
                          <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                          <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                        </svg>
                        <span>{exercise.solveCount} solves</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- Card Footer -->
                  <div class="px-6 py-4 bg-gray-50 dark:bg-gray-700/50 border-t border-gray-200 dark:border-gray-700">
                    <a 
                      href={`/exercises/${exercise.id}`}
                      class="w-full inline-flex justify-center items-center px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300"
                    >
                      {exercise.isCompleted ? 'Solved ✓' : 'Start Challenge'}
                      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ml-1">
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                        <polyline points="12 5 19 12 12 19"></polyline>
                      </svg>
                    </a>
                  </div>
                </div>
              {/each}
            </div>
          {:else}
            <!-- List View -->
            <div class="space-y-4">
              {#each paginatedExercises as exercise, i}
                <div 
                  in:fade={{ delay: 50 * i, duration: 300 }}
                  class="bg-white dark:bg-gray-800 rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden border border-gray-200 dark:border-gray-700"
                >
                  <div class="p-6">
                    <div class="flex flex-col md:flex-row md:items-center gap-4">
                      <!-- Left: Category Indicator -->
                      <div class="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-r from-emerald-400 to-cyan-500 flex items-center justify-center text-white text-2xl font-bold">
                        {exercise.category.substring(0, 2)}
                      </div>
                      
                      <!-- Middle: Title, Description, Tags -->
                      <div class="flex-grow">
                        <div class="flex flex-wrap items-start gap-2 mb-2">
                          <h3 class="text-xl font-bold">{exercise.title}</h3>
                          <span class={`text-xs font-medium px-2 py-1 rounded-full ${getDifficultyColor(exercise.difficulty)}`}>
                            {exercise.difficulty}
                          </span>
                          <span class="text-xs font-medium px-2 py-1 rounded-full bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300">
                            {exercise.category}
                          </span>
                        </div>
                        
                        <p class="text-gray-600 dark:text-gray-400 mb-3">{exercise.description}</p>
                        
                        <!-- Tags -->
                        {#if exercise.tags && exercise.tags.length > 0}
                          <div class="flex flex-wrap gap-1">
                            {#each exercise.tags as tag}
                              <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 px-2 py-1 rounded-full">
                                #{tag}
                              </span>
                            {/each}
                          </div>
                        {/if}
                      </div>
                      
                      <!-- Right: Stats and Button -->
                      <div class="flex flex-col md:items-end gap-4">
                        <div class="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400">
                          <div class="flex items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-1">
                              <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                            </svg>
                            <span>{exercise.points} pts</span>
                          </div>
                          <div class="flex items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mr-1">
                              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                              <circle cx="9" cy="7" r="4"></circle>
                              <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                              <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                            </svg>
                            <span>{exercise.solveCount} solves</span>
                          </div>
                        </div>
                        
                        <a 
                          href={`/exercises/${exercise.id}`}
                          class="inline-flex items-center px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300"
                        >
                          {exercise.isCompleted ? 'Solved ✓' : 'Start Challenge'}
                          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ml-1">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                          </svg>
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          {/if}
          
          <!-- Pagination -->
          {#if totalPages > 1}
            <div class="flex justify-center mt-8">
              <div class="flex items-center space-x-2">
                <!-- Previous Page -->
                <button
                  on:click={() => changePage(currentPage - 1)}
                  disabled={currentPage === 1}
                  class="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="15 18 9 12 15 6"></polyline>
                  </svg>
                </button>
                
                <!-- Page Numbers -->
                {#each Array(totalPages) as _, i}
                  {#if i + 1 === currentPage || i + 1 === 1 || i + 1 === totalPages || (i + 1 >= currentPage - 1 && i + 1 <= currentPage + 1)}
                    <button
                      on:click={() => changePage(i + 1)}
                      class={`px-4 py-2 rounded-lg ${currentPage === i + 1 ? 'bg-emerald-500 text-white' : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 border border-gray-300 dark:border-gray-600'}`}
                    >
                      {i + 1}
                    </button>
                  {:else if i + 1 === currentPage - 2 || i + 1 === currentPage + 2}
                    <span class="px-4 py-2 text-gray-500">...</span>
                  {/if}
                {/each}
                
                <!-- Next Page -->
                <button
                  on:click={() => changePage(currentPage + 1)}
                  disabled={currentPage === totalPages}
                  class="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="9 18 15 12 9 6"></polyline>
                  </svg>
                </button>
              </div>
            </div>
          {/if}
        {/if}
      </div>
    </section>
  </div>
  
  <style>
    /* Hide scrollbar but keep functionality */
    .hide-scrollbar {
      -ms-overflow-style: none;  /* IE and Edge */
      scrollbar-width: none;  /* Firefox */
    }
    
    .hide-scrollbar::-webkit-scrollbar {
      display: none; /* Chrome, Safari and Opera */
    }
    
    /* Line clamp for truncating text */
    .line-clamp-2 {
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .line-clamp-3 {
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
  </style>