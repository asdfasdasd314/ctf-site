<script lang="ts">
    import { onMount } from 'svelte';
    import { tweened } from 'svelte/motion';
    import { cubicOut } from 'svelte/easing';
    
    // Types
    type Category = 'Web' | 'Crypto' | 'Binary' | 'Forensics' | 'Reverse' | 'OSINT' | 'Network' | 'Misc';
    type Difficulty = 'Beginner' | 'Intermediate' | 'Advanced';
    
    interface CategoryStats {
      name: Category;
      total: number;
      solved: number;
      color: string;
    }
    
    interface DifficultyStats {
      name: Difficulty;
      total: number;
      solved: number;
    }
    
    // Sample user data - replace with actual data from your backend
    const userData = {
      username: 'hackerman',
      totalPoints: 2750,
      rank: 42,
      totalSolved: 18,
      totalExercises: 48,
      streak: 5, // days in a row with at least one solve
      lastActive: '2023-10-15T14:32:00Z',
    };
    
    // Sample category data - replace with actual data
    const categoryStats: CategoryStats[] = [
      { name: 'Web', total: 12, solved: 7, color: '#10b981' }, // emerald-500
      { name: 'Crypto', total: 8, solved: 4, color: '#3b82f6' }, // blue-500
      { name: 'Binary', total: 6, solved: 1, color: '#ef4444' }, // red-500
      { name: 'Forensics', total: 5, solved: 2, color: '#8b5cf6' }, // violet-500
      { name: 'Reverse', total: 7, solved: 2, color: '#f59e0b' }, // amber-500
      { name: 'OSINT', total: 3, solved: 1, color: '#ec4899' }, // pink-500
      { name: 'Network', total: 4, solved: 1, color: '#06b6d4' }, // cyan-500
      { name: 'Misc', total: 3, solved: 0, color: '#6b7280' }, // gray-500
    ];
    
    // Sample difficulty data - replace with actual data
    const difficultyStats: DifficultyStats[] = [
      { name: 'Beginner', total: 20, solved: 12 },
      { name: 'Intermediate', total: 18, solved: 5 },
      { name: 'Advanced', total: 10, solved: 1 },
    ];
    
    // Calculate total stats
    let totalExercises = categoryStats.reduce((sum, cat) => sum + cat.total, 0);
    let totalSolved = categoryStats.reduce((sum, cat) => sum + cat.solved, 0);
    let totalRemaining = totalExercises - totalSolved;
    let completionPercentage = Math.round((totalSolved / totalExercises) * 100);
    
    // Recent achievements - replace with actual data
    const recentAchievements = [
      { name: 'First Blood', description: 'First to solve a challenge', date: '2023-10-14' },
      { name: 'Persistence', description: '5-day solving streak', date: '2023-10-15' },
      { name: 'Web Warrior', description: 'Solved 5 web challenges', date: '2023-10-12' },
    ];
    
    // Pie chart calculations
    const radius = 80;
    const circumference = 2 * Math.PI * radius;
    
    // Animation for the progress circle
    const progressTween = tweened(0, {
      duration: 1000,
      easing: cubicOut
    });
    
    // Animation for the pie chart
    let chartVisible = false;
    
    // Calculate pie chart segments
    function calculatePieSegments() {
      let startAngle = 0;
      const segments = [];
      
      // First add the solved segment
      const solvedAngle = (totalSolved / totalExercises) * 360;
      segments.push({
        type: 'solved',
        startAngle,
        endAngle: startAngle + solvedAngle,
        color: '#10b981', // emerald-500
        percentage: (totalSolved / totalExercises) * 100
      });
      startAngle += solvedAngle;
      
      // Then add the remaining segment
      segments.push({
        type: 'remaining',
        startAngle,
        endAngle: 360,
        color: '#e5e7eb', // gray-200
        percentage: (totalRemaining / totalExercises) * 100
      });
      
      return segments;
    }
    
    // Convert angle to SVG arc path
    function describeArc(startAngle: number, endAngle: number) {
      const start = polarToCartesian(radius, startAngle);
      const end = polarToCartesian(radius, endAngle);
      const largeArcFlag = endAngle - startAngle <= 180 ? 0 : 1;
      
      return [
        'M', 100, 100,
        'L', start.x, start.y,
        'A', radius, radius, 0, largeArcFlag, 1, end.x, end.y,
        'Z'
      ].join(' ');
    }
    
    // Convert polar coordinates to cartesian
    function polarToCartesian(radius: number, angleInDegrees: number) {
      const angleInRadians = (angleInDegrees - 90) * Math.PI / 180;
      return {
        x: 100 + (radius * Math.cos(angleInRadians)),
        y: 100 + (radius * Math.sin(angleInRadians))
      };
    }
    
    // Calculate category segments for the detailed pie chart
    function calculateCategorySegments() {
      let startAngle = 0;
      const segments = [];
      
      for (const category of categoryStats) {
        const angle = (category.solved / totalExercises) * 360;
        if (angle > 0) {
          segments.push({
            name: category.name,
            startAngle,
            endAngle: startAngle + angle,
            color: category.color,
            solved: category.solved,
            total: category.total
          });
          startAngle += angle;
        }
      }
      
      // Add remaining segment if there are unsolved exercises
      if (totalRemaining > 0) {
        segments.push({
          name: 'Remaining',
          startAngle,
          endAngle: 360,
          color: '#e5e7eb', // gray-200
          solved: 0,
          total: totalRemaining
        });
      }
      
      return segments;
    }
    
    // Get difficulty color class
    function getDifficultyColor(difficulty: Difficulty): string {
      switch (difficulty) {
        case 'Beginner':
          return 'bg-green-500';
        case 'Intermediate':
          return 'bg-yellow-500';
        case 'Advanced':
          return 'bg-red-500';
        default:
          return 'bg-gray-500';
      }
    }
    
    // Format date to relative time (e.g., "2 days ago")
    function formatRelativeTime(dateString: string): string {
      const date = new Date(dateString);
      const now = new Date();
      const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);
      
      if (diffInSeconds < 60) return 'just now';
      if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} minutes ago`;
      if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} hours ago`;
      if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)} days ago`;
      
      return date.toLocaleDateString();
    }
    
    onMount(() => {
      // Animate progress
      progressTween.set(completionPercentage);
      
      // Show chart with slight delay
      setTimeout(() => {
        chartVisible = true;
      }, 300);
    });
  </script>
  
  <div class="dashboard-stats bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
    <h2 class="text-2xl font-bold mb-6 text-gray-800 dark:text-white">Your Progress</h2>
    
    <!-- Main Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <!-- Pie Chart -->
      <div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6 flex flex-col items-center justify-center col-span-1 md:col-span-1 relative">
        <div class="relative w-52 h-52">
          <!-- Main pie chart -->
          <svg width="200" height="200" viewBox="0 0 200 200" class="transform -rotate-90">
            {#if chartVisible}
              {#each calculatePieSegments() as segment, i}
                <path
                  d={describeArc(segment.startAngle, segment.endAngle)}
                  fill={segment.color}
                  stroke="white"
                  stroke-width="1"
                  class="transition-all duration-1000 ease-out"
                  style="opacity: {i === 0 ? 1 : 0.7};"
                />
              {/each}
            {/if}
          </svg>
          
          <!-- Center text -->
          <div class="absolute inset-0 flex flex-col items-center justify-center">
            <span class="text-3xl font-bold text-gray-800 dark:text-white">{completionPercentage}%</span>
            <span class="text-sm text-gray-500 dark:text-gray-400">Completed</span>
          </div>
        </div>
        
        <!-- Legend -->
        <div class="flex items-center justify-center gap-4 mt-4">
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-emerald-500 mr-2"></div>
            <span class="text-sm text-gray-600 dark:text-gray-300">Solved ({totalSolved})</span>
          </div>
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-gray-200 dark:bg-gray-500 mr-2"></div>
            <span class="text-sm text-gray-600 dark:text-gray-300">Remaining ({totalRemaining})</span>
          </div>
        </div>
      </div>
      
      <!-- Summary Stats -->
      <div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6 col-span-1 md:col-span-2">
        <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">Summary</h3>
        
        <div class="grid grid-cols-2 gap-4">
          <!-- Points -->
          <div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
            <div class="flex items-center">
              <div class="p-2 rounded-full bg-emerald-100 dark:bg-emerald-900 text-emerald-500 dark:text-emerald-300 mr-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Total Points</p>
                <p class="text-xl font-bold text-gray-800 dark:text-white">{userData.totalPoints}</p>
              </div>
            </div>
          </div>
          
          <!-- Rank -->
          <div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
            <div class="flex items-center">
              <div class="p-2 rounded-full bg-blue-100 dark:bg-blue-900 text-blue-500 dark:text-blue-300 mr-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M8.21 13.89L7 23l5-3 5 3-1.21-9.12"></path>
                  <circle cx="12" cy="8" r="7"></circle>
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Global Rank</p>
                <p class="text-xl font-bold text-gray-800 dark:text-white">#{userData.rank}</p>
              </div>
            </div>
          </div>
          
          <!-- Streak -->
          <div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
            <div class="flex items-center">
              <div class="p-2 rounded-full bg-orange-100 dark:bg-orange-900 text-orange-500 dark:text-orange-300 mr-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path>
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Current Streak</p>
                <p class="text-xl font-bold text-gray-800 dark:text-white">{userData.streak} days</p>
              </div>
            </div>
          </div>
          
          <!-- Last Active -->
          <div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
            <div class="flex items-center">
              <div class="p-2 rounded-full bg-purple-100 dark:bg-purple-900 text-purple-500 dark:text-purple-300 mr-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Last Active</p>
                <p class="text-md font-bold text-gray-800 dark:text-white">{formatRelativeTime(userData.lastActive)}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Category Progress -->
    <div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6 mb-8">
      <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">Progress by Category</h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        {#each categoryStats as category}
          <div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
            <div class="flex justify-between items-center mb-2">
              <div class="flex items-center">
                <div class="w-3 h-3 rounded-full mr-2" style="background-color: {category.color}"></div>
                <span class="font-medium text-gray-800 dark:text-white">{category.name}</span>
              </div>
              <span class="text-sm text-gray-500 dark:text-gray-400">
                {category.solved}/{category.total} ({Math.round((category.solved / category.total) * 100)}%)
              </span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2.5">
              <div 
                class="h-2.5 rounded-full transition-all duration-1000 ease-out"
                style="width: {(category.solved / category.total) * 100}%; background-color: {category.color}"
              ></div>
            </div>
          </div>
        {/each}
      </div>
    </div>
    
    <!-- Difficulty Progress -->
    <div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6 mb-8">
      <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">Progress by Difficulty</h3>
      
      <div class="space-y-4">
        {#each difficultyStats as difficulty}
          <div>
            <div class="flex justify-between items-center mb-2">
              <div class="flex items-center">
                <div class={`w-3 h-3 rounded-full mr-2 ${getDifficultyColor(difficulty.name)}`}></div>
                <span class="font-medium text-gray-800 dark:text-white">{difficulty.name}</span>
              </div>
              <span class="text-sm text-gray-500 dark:text-gray-400">
                {difficulty.solved}/{difficulty.total} ({Math.round((difficulty.solved / difficulty.total) * 100)}%)
              </span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2.5">
              <div 
                class={`h-2.5 rounded-full transition-all duration-1000 ease-out ${getDifficultyColor(difficulty.name)}`}
                style="width: {(difficulty.solved / difficulty.total) * 100}%"
              ></div>
            </div>
          </div>
        {/each}
      </div>
    </div>
    
    <!-- Detailed Category Breakdown -->
    <div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
      <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">Detailed Breakdown</h3>
      
      <div class="flex flex-col md:flex-row items-center gap-6">
        <!-- Detailed pie chart -->
        <div class="relative w-52 h-52 flex-shrink-0">
          <svg width="200" height="200" viewBox="0 0 200 200" class="transform -rotate-90">
            {#if chartVisible}
              {#each calculateCategorySegments() as segment, i}
                <path
                  d={describeArc(segment.startAngle, segment.endAngle)}
                  fill={segment.color}
                  stroke="white"
                  stroke-width="1"
                  class="transition-all duration-1000 ease-out"
                />
              {/each}
            {/if}
          </svg>
        </div>
        
        <!-- Legend for detailed chart -->
        <div class="grid grid-cols-2 gap-x-8 gap-y-2">
          {#each categoryStats.filter(cat => cat.solved > 0) as category}
            <div class="flex items-center">
              <div class="w-3 h-3 rounded-full mr-2" style="background-color: {category.color}"></div>
              <span class="text-sm text-gray-600 dark:text-gray-300">
                {category.name}: {category.solved} ({Math.round((category.solved / totalExercises) * 100)}%)
              </span>
            </div>
          {/each}
          {#if totalRemaining > 0}
            <div class="flex items-center">
              <div class="w-3 h-3 rounded-full bg-gray-200 dark:bg-gray-500 mr-2"></div>
              <span class="text-sm text-gray-600 dark:text-gray-300">
                Remaining: {totalRemaining} ({Math.round((totalRemaining / totalExercises) * 100)}%)
              </span>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
  
  <style>
    /* Add any additional styles here */
    .dashboard-stats {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
  </style>