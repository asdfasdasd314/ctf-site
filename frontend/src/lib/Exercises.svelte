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
		tags: string[];
		createdAt: string;
		link: string;
	}

	// UI state
	let isLoading = true;

	// Single exercise data
	let exercise: Exercise = {
		id: 1,
		title: 'Vulnerable Authentication',
		description:
			'Find and exploit vulnerabilities in the authentication system to gain unauthorized access.',
		difficulty: 'Beginner',
		category: 'Web',
		points: 100,
		solveCount: 0,
		isCompleted: false,
		tags: ['authentication', 'web-security', 'vulnerability'],
		createdAt: '2025-04-04',
		link: '/exercises/1'
	};

	onMount(() => {
		isLoading = false;
	});
</script>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 pb-20">
	<!-- Header -->
	<header class="bg-gradient-to-r from-emerald-600 to-cyan-600 py-16 px-4">
		<div class="container mx-auto max-w-6xl">
			<div in:fly={{ y: -20, duration: 800 }}>
				<h1 class="text-4xl md:text-5xl font-bold text-white mb-4">CTF Challenges</h1>
				<p class="text-emerald-100 text-lg md:text-xl max-w-2xl">
					Improve your skills in cybersecurity by solving challenges.
				</p>
			</div>
		</div>
	</header>

	<!-- Exercise Section -->
	<section class="py-8">
		<div class="container mx-auto max-w-4xl px-4">
			{#if isLoading}
				<div class="text-center py-20">
					<svg
						class="animate-spin mx-auto h-12 w-12 text-emerald-500"
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
					>
						<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"
						></circle>
						<path
							class="opacity-75"
							fill="currentColor"
							d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
						></path>
					</svg>
				</div>
			{:else}
				<div
					in:fade={{ duration: 300 }}
					class="bg-white dark:bg-gray-800 rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden border border-gray-200 dark:border-gray-700"
				>
					<!-- Card Header with Category Background -->
					<div class="h-3 bg-gradient-to-r from-emerald-400 to-cyan-500"></div>

					<div class="p-6">
						<!-- Title and Difficulty -->
						<div class="flex justify-between items-start mb-3">
							<h3 class="text-lg font-bold">{exercise.title}</h3>
							<span
								class="text-xs font-medium px-2 py-1 rounded-full ml-2 whitespace-nowrap bg-emerald-100 text-emerald-800 dark:bg-emerald-900/50 dark:text-emerald-200"
							>
								{exercise.difficulty}
							</span>
						</div>

						<!-- Description -->
						<p class="text-gray-600 dark:text-gray-400 text-sm mb-4">{exercise.description}</p>

						<!-- Tags -->
						<div class="flex flex-wrap gap-1 mb-4">
							{#each exercise.tags as tag}
								<span
									class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 px-2 py-1 rounded-full"
								>
									#{tag}
								</span>
							{/each}
						</div>

						<!-- Stats -->
						<div class="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-4">
							<div class="flex items-center">
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="16"
									height="16"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
									stroke-linejoin="round"
									class="mr-1"
								>
									<polygon
										points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"
									></polygon>
								</svg>
								<span>{exercise.points} pts</span>
							</div>
							<div class="flex items-center">
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="16"
									height="16"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
									stroke-linejoin="round"
									class="mr-1"
								>
									<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
									<circle cx="9" cy="7" r="4"></circle>
									<path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
									<path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
								</svg>
								<span>{exercise.solveCount} solves</span>
							</div>
						</div>

						<!-- Start Challenge Button -->
						<a
							href={exercise.link}
							class="w-full inline-flex justify-center items-center px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300"
						>
							{exercise.isCompleted ? 'Solved ✓' : 'Start Challenge'}
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="18"
								height="18"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
								class="ml-1"
							>
								<line x1="5" y1="12" x2="19" y2="12"></line>
								<polyline points="12 5 19 12 12 19"></polyline>
							</svg>
						</a>
					</div>
				</div>
			{/if}
		</div>
	</section>
</div>

<style>
	/* Hide scrollbar but keep functionality */
	.hide-scrollbar {
		-ms-overflow-style: none; /* IE and Edge */
		scrollbar-width: none; /* Firefox */
	}

	.hide-scrollbar::-webkit-scrollbar {
		display: none; /* Chrome, Safari and Opera */
	}
</style>

