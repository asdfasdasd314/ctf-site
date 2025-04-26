<script lang="ts">
	import { onMount } from 'svelte';
	import { Tween } from 'svelte/motion';
	import { cubicOut } from 'svelte/easing';
	import { getExercises } from './exercises';
	import type { Exercise } from './exercises';

	// Types
	type Category =
		| 'Web'
		| 'Crypto'
		| 'Binary'
		| 'Forensics'
		| 'Reverse'
		| 'OSINT'
		| 'Network'
		| 'Misc';
	type Difficulty = 'Easy' | 'Medium' | 'Hard';

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

	// State variables
	let allExercises = $state<Exercise[]>([]);
	let isLoading = $state(true);
	let error = $state<string | null>(null);

	// Calculate stats from exercises
	let categoryStats = $state<CategoryStats[]>([]);
	let difficultyStats = $state<DifficultyStats[]>([]);
	let userData = $state({
		totalPoints: 0,
		totalSolved: 0,
		totalExercises: 0,
		streak: 0,
		createdAt: new Date().toISOString()
	});

	// Calculate total stats
	let totalExercises = $derived(categoryStats.reduce((sum, cat) => sum + cat.total, 0));
	let totalSolved = $derived(categoryStats.reduce((sum, cat) => sum + cat.solved, 0));
	let totalRemaining = $derived(totalExercises - totalSolved);
	let completionPercentage = $derived(totalExercises > 0 ? Math.round((totalSolved / totalExercises) * 100) : 0);

	// Pie chart calculations
	const radius = 80;

	// Animation for the progress circle
	const progressTween = new Tween(0, {
		duration: 1000,
		easing: cubicOut
	});

	// Animation for the pie chart
	let chartVisible = $state(false);

	// Calculate pie chart segments
	function calculatePieSegments() {
		let startAngle = 0;
		const segments = [];

		// If no exercises are solved, show a full gray circle
		if (totalSolved === 0) {
			segments.push({
				type: 'remaining',
				startAngle: 0,
				endAngle: 360,
				color: '#e5e7eb', // gray-200
				percentage: 100
			});
			return segments;
		}

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

		// Then add the remaining segment if there are any remaining exercises
		if (totalRemaining > 0) {
			segments.push({
				type: 'remaining',
				startAngle,
				endAngle: 360,
				color: '#e5e7eb', // gray-200
				percentage: (totalRemaining / totalExercises) * 100
			});
		}

		return segments;
	}

	// Convert angle to SVG arc path
	function describeArc(startAngle: number, endAngle: number) {
		// Special case for full circle (360 degrees)
		if (endAngle - startAngle === 360) {
			return `M 100,100 m -${radius},0 a ${radius},${radius} 0 1,0 ${radius * 2},0 a ${radius},${radius} 0 1,0 -${radius * 2},0`;
		}

		const start = polarToCartesian(radius, startAngle);
		const end = polarToCartesian(radius, endAngle);
		// Calculate whether to use large arc based on angle difference
		const angleDiff = endAngle - startAngle;
		const largeArcFlag = angleDiff > 180 ? 1 : 0;

		return [
			'M',
			100,
			100,
			'L',
			start.x,
			start.y,
			'A',
			radius,
			radius,
			0,
			largeArcFlag,
			1,
			end.x,
			end.y,
			'Z'
		].join(' ');
	}

	// Convert polar coordinates to cartesian
	function polarToCartesian(radius: number, angleInDegrees: number) {
		const angleInRadians = ((angleInDegrees - 90) * Math.PI) / 180;
		return {
			x: 100 + radius * Math.cos(angleInRadians),
			y: 100 + radius * Math.sin(angleInRadians)
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
				color: '#e5e7eb',
				solved: 0,
				total: totalRemaining
			});
		}

		return segments;
	}

	// Get difficulty color class
	function getDifficultyColor(difficulty: Difficulty): string {
		switch (difficulty) {
			case 'Easy':
				return 'bg-green-500';
			case 'Medium':
				return 'bg-yellow-500';
			case 'Hard':
				return 'bg-red-500';
			default:
				return 'bg-gray-500';
		}
	}

	// Format date to relative time (e.g., "2 days ago")
	function formatRelativeTime(dateString: string): string {
		// Parse the date string and convert to local timezone
		const date = new Date(dateString + 'Z'); // Add 'Z' to indicate UTC time
		const now = new Date();
		const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

		if (diffInSeconds < 60) return `${diffInSeconds} seconds ago`;
		if (diffInSeconds < 3600) {
			const minutes = Math.floor(diffInSeconds / 60);
			return `${minutes} ${minutes === 1 ? 'minute' : 'minutes'} ago`;
		}
		if (diffInSeconds < 86400) {
			const hours = Math.floor(diffInSeconds / 3600);
			return `${hours} ${hours === 1 ? 'hour' : 'hours'} ago`;
		}
		if (diffInSeconds < 604800) {
			const days = Math.floor(diffInSeconds / 86400);
			return `${days} ${days === 1 ? 'day' : 'days'} ago`;
		}
		if (diffInSeconds < 2592000) {
			const weeks = Math.floor(diffInSeconds / 604800);
			return `${weeks} ${weeks === 1 ? 'week' : 'weeks'} ago`;
		}
		if (diffInSeconds < 31536000) {
			const months = Math.floor(diffInSeconds / 2592000);
			return `${months} ${months === 1 ? 'month' : 'months'} ago`;
		}

		const years = Math.floor(diffInSeconds / 31536000);
		return `${years} ${years === 1 ? 'year' : 'years'} ago`;
	}

	// Update stats based on exercises
	function updateStats() {
		// Reset stats
		categoryStats = [
			{ name: 'Web', total: 0, solved: 0, color: '#10b981' },
			{ name: 'Crypto', total: 0, solved: 0, color: '#3b82f6' },
			{ name: 'Binary', total: 0, solved: 0, color: '#ef4444' },
			{ name: 'Forensics', total: 0, solved: 0, color: '#8b5cf6' },
			{ name: 'Reverse', total: 0, solved: 0, color: '#f59e0b' },
			{ name: 'OSINT', total: 0, solved: 0, color: '#ec4899' },
			{ name: 'Network', total: 0, solved: 0, color: '#06b6d4' },
			{ name: 'Misc', total: 0, solved: 0, color: '#6b7280' }
		];

		difficultyStats = [
			{ name: 'Easy', total: 0, solved: 0 },
			{ name: 'Medium', total: 0, solved: 0 },
			{ name: 'Hard', total: 0, solved: 0 }
		];

		// Update category stats
		for (const exercise of allExercises) {
			const category = categoryStats.find(cat => cat.name.toLowerCase() === exercise.category.toLowerCase());
			if (category) {
				category.total++;
				if (exercise.isCompleted) {
					category.solved++;
				}
			}
		}

		// Update difficulty stats
		for (const exercise of allExercises) {
			const difficulty = difficultyStats.find(d => d.name.toLowerCase() === exercise.difficulty.toLowerCase());
			if (difficulty) {
				difficulty.total++;
				if (exercise.isCompleted) {
					difficulty.solved++;
				}
			}
		}

		// Update user data
		userData = {
			totalPoints: allExercises.reduce((sum, ex) => sum + (ex.isCompleted ? ex.points : 0), 0),
			totalSolved: allExercises.filter(ex => ex.isCompleted).length,
			totalExercises: allExercises.length,
			streak: 0, // TODO: Implement streak calculation
			createdAt: userData.createdAt
		};
	}

	onMount(async () => {
		try {
			// Fetch all exercises
			allExercises = await getExercises();

			// Fetch completed exercises
			const response = await fetch('/api/exercises/completed', {
				credentials: 'include'
			});
			const data = await response.json();
			if (data.success) {
				// Update isCompleted flag for each exercise
				allExercises = allExercises.map(exercise => ({
					...exercise,
					isCompleted: data.exercises.some((ce: any) => ce.exercise_id === exercise.exerciseId)
				}));
			} else {
				throw new Error(data.err || 'Failed to fetch completed exercises');
			}

			// Fetch account creation date
			const creationDateResponse = await fetch('/api/user/creation-date', {
				credentials: 'include'
			});
			const creationDateData = await creationDateResponse.json();
			if (creationDateData.success) {
				userData.createdAt = creationDateData.created_at;
			}

			// Update stats
			updateStats();

			// Animate progress
			progressTween.set(completionPercentage);

			// Show chart with slight delay
			setTimeout(() => {
				chartVisible = true;
			}, 300);
		} catch (err) {
			error = err instanceof Error ? err.message : 'An unknown error occurred';
		} finally {
			isLoading = false;
		}
	});
</script>

<div class="dashboard-stats bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6">
	<h2 class="text-2xl font-bold mb-6 text-gray-800 dark:text-white">Your Progress</h2>

	<!-- Main Stats Grid -->
	<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
		<!-- Pie Chart -->
		<div
			class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6 flex flex-col items-center justify-center col-span-1 md:col-span-1 relative"
		>
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
								style="opacity: {segment.type === 'solved' ? 1 : 0.7};"
							/>
						{/each}
					{/if}
				</svg>

				<!-- Center text -->
				<div class="absolute inset-0 flex flex-col items-center justify-center">
					<span class="text-3xl font-bold text-gray-800 dark:text-white"
						>{completionPercentage}%</span
					>
					<span class="text-sm text-gray-600 dark:text-gray-500">Completed</span>
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
						<div
							class="p-2 rounded-full bg-emerald-100 dark:bg-emerald-900 text-emerald-500 dark:text-emerald-300 mr-3"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="20"
								height="20"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
							>
								<polygon
									points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"
								></polygon>
							</svg>
						</div>
						<div>
							<p class="text-sm text-gray-500 dark:text-gray-400">Total Points</p>
							<p class="text-xl font-bold text-gray-800 dark:text-white">{userData.totalPoints}</p>
						</div>
					</div>
				</div>

				<!-- Streak -->
				<div class="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
					<div class="flex items-center">
						<div
							class="p-2 rounded-full bg-orange-100 dark:bg-orange-900 text-orange-500 dark:text-orange-300 mr-3"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="20"
								height="20"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
							>
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
						<div
							class="p-2 rounded-full bg-purple-100 dark:bg-purple-900 text-purple-500 dark:text-purple-300 mr-3"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="20"
								height="20"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
							>
								<circle cx="12" cy="12" r="10"></circle>
								<polyline points="12 6 12 12 16 14"></polyline>
							</svg>
						</div>
						<div>
							<p class="text-sm text-gray-500 dark:text-gray-400">Account Created</p>
							<p class="text-md font-bold text-gray-800 dark:text-white">
								{formatRelativeTime(userData.createdAt)}
							</p>
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
							<div
								class="w-3 h-3 rounded-full mr-2"
								style="background-color: {category.color}"
							></div>
							<span class="font-medium text-gray-800 dark:text-white">{category.name}</span>
						</div>
						<span class="text-sm text-gray-500 dark:text-gray-400">
							{category.solved}/{category.total} {category.total > 0 ? `(${Math.round(
								(category.solved / category.total) * 100
							)}%)` : '(0%)'}
						</span>
					</div>
					<div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2.5">
						<div
							class="h-2.5 rounded-full transition-all duration-1000 ease-out"
							style="width: {category.total > 0 ? (category.solved / category.total) * 100 : 0}%; background-color: {category.color}"
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
							{difficulty.solved}/{difficulty.total} {difficulty.total > 0 ? `(${Math.round(
								(difficulty.solved / difficulty.total) * 100
							)}%)` : '(0%)'}
						</span>
					</div>
					<div class="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2.5">
						<div
							class={`h-2.5 rounded-full transition-all duration-1000 ease-out ${getDifficultyColor(difficulty.name)}`}
							style="width: {difficulty.total > 0 ? (difficulty.solved / difficulty.total) * 100 : 0}%"
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
								style="opacity: {segment.name === 'Remaining' ? 0.7 : 1};"
							/>
						{/each}
					{/if}
				</svg>
			</div>

			<!-- Legend for detailed chart -->
			<div class="grid grid-cols-2 gap-x-8 gap-y-2">
				{#each categoryStats.filter((cat) => cat.solved > 0) as category}
					<div class="flex items-center">
						<div class="w-3 h-3 rounded-full mr-2" style="background-color: {category.color}"></div>
						<span class="text-sm text-gray-600 dark:text-gray-300">
							{category.name}: {category.solved} ({Math.round(
								(category.solved / totalExercises) * 100
							)}%)
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

	<!-- User Stats -->
	<div class="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
		<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
			<div class="text-center">
				<div class="text-2xl font-bold text-gray-800 dark:text-white">{userData.totalPoints}</div>
				<div class="text-sm text-gray-600 dark:text-gray-400">Total Points</div>
			</div>
			<div class="text-center">
				<div class="text-2xl font-bold text-gray-800 dark:text-white">{userData.totalSolved}</div>
				<div class="text-sm text-gray-600 dark:text-gray-400">Solved</div>
			</div>
			<div class="text-center">
				<div class="text-2xl font-bold text-gray-800 dark:text-white">{userData.streak}</div>
				<div class="text-sm text-gray-600 dark:text-gray-400">Day Streak</div>
			</div>
			<div class="text-center">
				<div class="text-2xl font-bold text-gray-800 dark:text-white">{formatRelativeTime(userData.createdAt)}</div>
				<div class="text-sm text-gray-600 dark:text-gray-400">Account Created</div>
			</div>
		</div>
	</div>
</div>

<style>
	/* Add any additional styles here */
	.dashboard-stats {
		font-family:
			system-ui,
			-apple-system,
			BlinkMacSystemFont,
			'Segoe UI',
			Roboto,
			sans-serif;
	}
</style>
