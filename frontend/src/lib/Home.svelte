<script lang="ts">
	import { onMount } from 'svelte';
	import { fly, fade, scale } from 'svelte/transition';

	import objdump from '$lib/assets/objdump.png';

	// For the scrolling exercises bar
	let exercisesContainer: HTMLElement;
	let isDragging = false;
	let startX: number;
	let scrollLeft: number;

	// Sample exercises - replace with your actual exercises
	const exercises = [
		{ id: 1, title: 'Web Exploitation Basics', difficulty: 'Beginner', category: 'Web' },
		{ id: 2, title: 'Cryptography Challenges', difficulty: 'Intermediate', category: 'Crypto' },
		{ id: 3, title: 'Binary Exploitation', difficulty: 'Advanced', category: 'Binary' },
		{ id: 4, title: 'Forensics Investigation', difficulty: 'Intermediate', category: 'Forensics' },
		{ id: 5, title: 'Reverse Engineering 101', difficulty: 'Beginner', category: 'Reverse' },
		{ id: 6, title: 'OSINT Challenges', difficulty: 'Beginner', category: 'OSINT' },
		{ id: 7, title: 'Network Security', difficulty: 'Intermediate', category: 'Network' },
		{ id: 8, title: 'Advanced Cryptography', difficulty: 'Advanced', category: 'Crypto' }
	];

	// Learning resources
	const resources = [
		{
			name: 'Pico CTF',
			url: 'https://picoctf.org',
			description:
				'This was the main resource I used because they offer fun and challenging exercises!'
		},
		{
			name: 'Pwnable',
			url: 'https://www.pwnable.tw/',
			description:
				"Some weird stuff happens with this site... but it's great for binary exploitation"
		},

		// These two were by v0
		{
			name: 'TryHackMe',
			url: 'https://tryhackme.com/',
			description: 'Learn cybersecurity through hands-on exercises'
		},
		{
			name: 'PortSwigger Web Security Academy',
			url: 'https://portswigger.net/web-security',
			description: 'Free web security training'
		}
	];

	// Handle horizontal scrolling for exercises
	function startDrag(e: MouseEvent) {
		isDragging = true;
		startX = e.pageX - exercisesContainer.offsetLeft;
		scrollLeft = exercisesContainer.scrollLeft;
		exercisesContainer.style.cursor = 'grabbing';
	}

	function endDrag() {
		isDragging = false;
		exercisesContainer.style.cursor = 'grab';
	}

	function drag(e: MouseEvent) {
		if (!isDragging) return;
		e.preventDefault();
		const x = e.pageX - exercisesContainer.offsetLeft;
		const walk = (x - startX) * 2; // Scroll speed multiplier
		exercisesContainer.scrollLeft = scrollLeft - walk;
	}

	onMount(() => {
		// Add event listeners for the exercises scrolling
		exercisesContainer.addEventListener('mousedown', startDrag);
		window.addEventListener('mouseup', endDrag);
		window.addEventListener('mousemove', drag);

		return () => {
			exercisesContainer.removeEventListener('mousedown', startDrag);
			window.removeEventListener('mouseup', endDrag);
			window.removeEventListener('mousemove', drag);
		};
	});
</script>

<main class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
	<!-- Hero Section -->
	<section class="relative py-20 overflow-hidden">
		<div class="container mx-auto px-4">
			<div class="flex flex-col md:flex-row items-center">
				<div class="z-1 md:w-1/2 mb-10 md:mb-0" in:fly={{ y: 50, duration: 1000 }}>
					<h1 class="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
						Master Cybersecurity Through <span class="text-emerald-500">Challenges</span>
					</h1>
					<p class="text-lg md:text-xl mb-8 text-gray-700 dark:text-gray-300">
						Sharpen your hacking skills with our collection of Capture The Flag challenges designed
						for all skill levels.
					</p>
					<div class="flex flex-wrap gap-4">
						<a
							href="#exercises"
							class="px-6 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300"
						>
							Start Hacking
						</a>
						<a
							href="#what-is-ctf"
							class="px-6 py-3 bg-transparent border border-emerald-500 text-emerald-500 hover:bg-emerald-500 hover:text-white font-medium rounded-lg transition-colors duration-300"
						>
							Learn More
						</a>
					</div>
				</div>
				<div class="md:w-1/2 relative" in:fade={{ delay: 300, duration: 1000 }}>
					<div class="relative w-full h-64 md:h-96">
						<div class="absolute inset-0 flex justify-center items-start">
							<img src={objdump} alt="Terminal" class="object-contain h-full" />
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Background decorative elements -->
		<div
			class="absolute -bottom-16 -left-16 w-64 h-64 bg-emerald-500 opacity-10 rounded-full"
		></div>
		<div class="absolute top-20 right-10 w-32 h-32 bg-emerald-500 opacity-10 rounded-full"></div>
	</section>

	<!-- What is CTF Section -->
	<section id="what-is-ctf" class="py-20 bg-white dark:bg-gray-800">
		<div class="container mx-auto px-4">
			<h2 class="text-3xl md:text-4xl font-bold mb-12 text-center">
				What is <span class="text-emerald-500">CTF?</span>
			</h2>

			<div class="grid md:grid-cols-2 gap-12 items-center">
				<div in:fly={{ x: -50, duration: 1000 }}>
					<img
						src="/placeholder.svg?height=400&width=600"
						alt="A pic of one of my exercises will go here"
						class="rounded-lg shadow-lg w-full"
					/>
				</div>

				<div class="space-y-6" in:fly={{ x: 50, duration: 1000, delay: 200 }}>
					<div>
						<h3 class="text-2xl font-semibold mb-3 flex items-center">
							<span
								class="inline-block w-8 h-8 bg-emerald-500 text-white rounded-full mr-3 items-center text-center justify-center"
								>1</span
							>
							Capture The Flag
						</h3>
						<p class="text-gray-700 dark:text-gray-300">
							CTF (Capture The Flag) is a type of computer security competition where participants
							solve cybersecurity challenges to find hidden "flags" - secret strings that prove
							they've solved the challenge.
						</p>
					</div>

					<div>
						<h3 class="text-2xl font-semibold mb-3 flex items-center">
							<span
								class="inline-block w-8 h-8 bg-emerald-500 text-white rounded-full mr-3 items-center text-center justify-center"
								>2</span
							>
							Types of Challenges
						</h3>
						<p class="text-gray-700 dark:text-gray-300">
							CTFs include various categories like web exploitation, cryptography, reverse
							engineering, binary exploitation, forensics, and more. Each tests different
							cybersecurity skills.
						</p>
					</div>

					<div>
						<h3 class="text-2xl font-semibold mb-3 flex items-center">
							<span
								class="inline-block w-8 h-8 bg-emerald-500 text-white rounded-full mr-3 items-center text-center justify-center"
								>3</span
							>
							Learning by Doing
						</h3>
						<p class="text-gray-700 dark:text-gray-300">
							CTFs are an excellent way to learn cybersecurity concepts hands-on. They simulate
							real-world scenarios and vulnerabilities in a controlled environment.
						</p>
					</div>
				</div>
			</div>
		</div>
	</section>

	<!-- Exercises Scrolling Bar -->
	<section id="exercises" class="py-20 bg-gray-50 dark:bg-gray-900">
		<div class="container mx-auto px-4">
			<h2 class="text-3xl md:text-4xl font-bold mb-6 text-center">
				Featured <span class="text-emerald-500">Challenges</span>
			</h2>
			<p class="text-center text-gray-700 dark:text-gray-300 mb-12 max-w-2xl mx-auto">
				Explore our collection of cybersecurity challenges designed to test and improve your skills.
				Drag to scroll through the challenges.
			</p>

			<!-- Scrollable exercises container -->
			<div
				bind:this={exercisesContainer}
				class="flex overflow-x-auto pb-6 cursor-grab hide-scrollbar"
				style="scroll-behavior: smooth;"
			>
				<div class="flex gap-6 px-4">
					{#each exercises as exercise, i}
						<div
							in:scale={{ delay: 100 * i, duration: 500, start: 0.8 }}
							class="flex-shrink-0 w-72 bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden border border-gray-200 dark:border-gray-700 hover:shadow-xl transition-shadow duration-300"
						>
							<div
								class="h-40 bg-gradient-to-r from-emerald-400 to-cyan-500 flex items-center justify-center"
							>
								<span class="text-6xl text-white opacity-80">{exercise.category[0]}</span>
							</div>
							<div class="p-6">
								<div class="flex justify-between items-center mb-3">
									<span
										class="text-sm font-medium px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200"
									>
										{exercise.category}
									</span>
									<span class="text-sm text-gray-500 dark:text-gray-400">{exercise.difficulty}</span
									>
								</div>
								<h3 class="text-xl font-bold mb-2">{exercise.title}</h3>
								<a
									href={`/exercises/${exercise.id}`}
									class="mt-4 inline-block text-emerald-500 hover:text-emerald-600 font-medium"
								>
									Start Challenge →
								</a>
							</div>
						</div>
					{/each}
				</div>
			</div>

			<!-- Scroll indicator -->
			<div class="flex justify-center mt-6">
				<div class="flex items-center gap-2">
					<span class="text-sm text-gray-500 dark:text-gray-400">Drag to explore more</span>
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
						class="text-emerald-500 animate-pulse"
					>
						<path d="M17 8l4 4-4 4M3 12h18"></path>
					</svg>
				</div>
			</div>
		</div>
	</section>

	<!-- Learning Resources -->
	<section class="py-20 bg-white dark:bg-gray-800">
		<div class="container mx-auto px-4">
			<h2 class="text-3xl md:text-4xl font-bold mb-6 text-center">
				Learning <span class="text-emerald-500">Resources</span>
			</h2>
			<p class="text-center text-gray-700 dark:text-gray-300 mb-12 max-w-2xl mx-auto">
				Enhance your cybersecurity knowledge with these valuable resources and platforms.
			</p>

			<div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
				{#each resources as resource, i}
					<div
						in:fly={{ y: 30, delay: 150 * i, duration: 800 }}
						class="bg-gray-50 dark:bg-gray-900 p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300"
					>
						<h3 class="text-xl font-bold mb-3">{resource.name}</h3>
						<p class="text-gray-700 dark:text-gray-300 mb-4">{resource.description}</p>
						<a
							href={resource.url}
							target="_blank"
							rel="noopener noreferrer"
							class="text-emerald-500 hover:text-emerald-600 font-medium inline-flex items-center"
						>
							Visit Site
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
								<path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"></path>
								<path d="M15 3h6v6"></path>
								<path d="M10 14L21 3"></path>
							</svg>
						</a>
					</div>
				{/each}
			</div>
		</div>
	</section>

	<!-- Call to Action -->
	<section class="py-20 bg-gradient-to-r from-emerald-500 to-cyan-500 text-white">
		<div class="container mx-auto px-4 text-center">
			<h2 class="text-3xl md:text-4xl font-bold mb-6">Ready to Test Your Skills?</h2>
			<p class="max-w-2xl mx-auto mb-8 text-lg opacity-90">
				Join our community of cybersecurity enthusiasts and start solving challenges today.
			</p>
			<a
				href="#exercises"
				class="px-8 py-4 bg-white text-emerald-600 font-bold rounded-lg shadow-lg hover:bg-gray-100 transition-colors duration-300 inline-block"
			>
				Start Hacking Now
			</a>
		</div>
	</section>
</main>

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
