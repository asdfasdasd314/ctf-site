<script lang="ts">
	import * as auth from '$lib/userAuth';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { fly, fade } from 'svelte/transition';

	let enteringData = $state(false);
	let isLoading = $state(false);
	let validationError = $state('');

	onMount(async () => {
		if (!(await auth.checkAuth())) {
			goto('/login');
		}
	});

	const deleteAccount = async (event: SubmitEvent) => {
		event.preventDefault();
		const form = event.target as HTMLFormElement;
		const formData = new FormData(form);
		const username = formData.get('username') as string;
		const password = formData.get('password') as string;

		isLoading = true;
		const res = await fetch('/api/delete-account', {
			method: 'POST',
			credentials: 'include',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({ username, password })
		});

		if (res.status === 200) {
			// As we will redirect, we don't have to reset the validationError
			auth.loggedIn.set(false);
			enteringData = false;
			await goto('/login');
		} else if (res.status === 401) {
			validationError = 'Invalid username or password';
		} else {
			validationError =
				'Error trying to delete account, maybe try again? If this keeps happening, please contact support.';
		}
		isLoading = false;
	};

	const signOut = async () => {
		isLoading = true;
		const res = await fetch('/api/logout', {
			method: 'POST',
			credentials: 'include',
			headers: {
				'Content-Type': 'application/json'
			}
		});

		if (res.status === 200) {
			auth.loggedIn.set(false);
			await goto('/login');
		}
		isLoading = false;
	};
</script>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
	<!-- Header -->
	<header class="bg-gradient-to-r from-emerald-600 to-cyan-600 py-16 px-4">
		<div class="container mx-auto max-w-6xl">
			<div in:fly={{ y: -20, duration: 800 }}>
				<h1 class="text-4xl md:text-5xl font-bold text-white mb-4">Dashboard</h1>
				<p class="text-emerald-100 text-lg md:text-xl max-w-2xl">
					Manage your account and track your progress across challenges.
				</p>
			</div>
		</div>
	</header>

	<!-- Dashboard Content -->
	<section class="py-12">
		<div class="container mx-auto max-w-4xl px-4">
			<div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8" in:fade={{ duration: 500 }}>
				<!-- Account Actions -->
				<div class="space-y-6">
					<!-- Sign Out Button -->
					<div
						class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg"
					>
						<div>
							<h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Sign Out</h3>
							<p class="text-sm text-gray-600 dark:text-gray-400">Sign out of your account</p>
						</div>
						<button
							onclick={signOut}
							disabled={isLoading}
							class="px-4 py-2 bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500 rounded-lg transition-colors duration-300 flex items-center"
						>
							{#if isLoading}
								<svg
									class="animate-spin -ml-1 mr-2 h-4 w-4 text-gray-500"
									xmlns="http://www.w3.org/2000/svg"
									fill="none"
									viewBox="0 0 24 24"
								>
									<circle
										class="opacity-25"
										cx="12"
										cy="12"
										r="10"
										stroke="currentColor"
										stroke-width="4"
									></circle>
									<path
										class="opacity-75"
										fill="currentColor"
										d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
									></path>
								</svg>
								Signing out...
							{:else}
								Sign Out
							{/if}
						</button>
					</div>

					<!-- Delete Account Section -->
					<div class="p-4 bg-red-50 dark:bg-red-900/20 rounded-lg">
						<div class="flex items-center justify-between mb-4">
							<div>
								<h3 class="text-lg font-medium text-red-800 dark:text-red-200">Delete Account</h3>
								<p class="text-sm text-red-700 dark:text-red-300">
									Permanently delete your account and all associated data
								</p>
							</div>
							{#if !enteringData}
								<button
									onclick={() => (enteringData = true)}
									class="px-4 py-2 bg-red-100 dark:bg-red-900/50 text-red-700 dark:text-red-200 hover:bg-red-200 dark:hover:bg-red-900/70 rounded-lg transition-colors duration-300"
								>
									Delete Account
								</button>
							{/if}
						</div>

						{#if enteringData}
							<form onsubmit={deleteAccount} class="space-y-4">
								<div>
									<label
										for="username"
										class="block text-sm font-medium text-red-700 dark:text-red-300 mb-2"
									>
										Username
									</label>
									<input
										type="text"
										id="username"
										name="username"
										placeholder="Enter your username"
										class="w-full px-4 py-2 rounded-lg border border-red-300 dark:border-red-700 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-red-500 focus:border-red-500 dark:focus:ring-red-400 dark:focus:border-red-400 outline-none transition-all"
										required
									/>
								</div>

								<div>
									<label
										for="password"
										class="block text-sm font-medium text-red-700 dark:text-red-300 mb-2"
									>
										Password
									</label>
									<input
										type="password"
										id="password"
										name="password"
										placeholder="Enter your password"
										class="w-full px-4 py-2 rounded-lg border border-red-300 dark:border-red-700 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-red-500 focus:border-red-500 dark:focus:ring-red-400 dark:focus:border-red-400 outline-none transition-all"
										required
									/>
								</div>

								{#if validationError}
									<div
										class="bg-red-50 dark:bg-red-900/50 text-red-700 dark:text-red-200 p-4 rounded-lg text-sm"
									>
										{validationError}
									</div>
								{/if}

								<div class="flex gap-4">
									<button
										type="submit"
										disabled={isLoading}
										class="flex-1 px-4 py-2 bg-red-500 hover:bg-red-600 text-white font-medium rounded-lg transition-colors duration-300 flex items-center justify-center"
									>
										{#if isLoading}
											<svg
												class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
												xmlns="http://www.w3.org/2000/svg"
												fill="none"
												viewBox="0 0 24 24"
											>
												<circle
													class="opacity-25"
													cx="12"
													cy="12"
													r="10"
													stroke="currentColor"
													stroke-width="4"
												></circle>
												<path
													class="opacity-75"
													fill="currentColor"
													d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
												></path>
											</svg>
											Deleting...
										{:else}
											Confirm Delete
										{/if}
									</button>
									<button
										type="button"
										onclick={() => {
											enteringData = false;
											validationError = '';
										}}
										class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500 rounded-lg transition-colors duration-300"
									>
										Cancel
									</button>
								</div>
							</form>
						{/if}
					</div>
				</div>
			</div>
		</div>
	</section>
</div>

<style>
</style>

