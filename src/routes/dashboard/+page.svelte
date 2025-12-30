<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import DashboardStats from '$lib/DashboardStats.svelte';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { fly, fade } from 'svelte/transition';

	let enteringData = $state(false);
	let isLoading = $state(false);
	let validationError = $state('');
	let email = $state('');

	onMount(async () => {
		const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
		if (sessionError) {
			console.error('Error getting session:', sessionError);
			goto('/login');
			return;
		} else if (!sessionData.session) {
			goto('/login');
			return;
		}

		email = sessionData.session?.user.email ?? '';
	});

	const deleteAccount = async (event: SubmitEvent) => {
		event.preventDefault();
		const form = event.target as HTMLFormElement;
		const formData = new FormData(form);
		const confirmation = formData.get('confirmation') as string;
		if (confirmation !== 'Delete my account') {
			validationError = 'Invalid confirmation. Please type "Delete my account" to confirm.';
			return;
		}

		isLoading = true;

		const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
		if (sessionError) {
			console.error('Error getting session:', sessionError);
			isLoading = false;
			return;
		}
		if (!sessionData.session) {
			// This is not very likely, but just in case
			validationError = 'User not signed in, cannot delete account.';
			isLoading = false;
			return;
		}

		try {
			const response = await fetch('/api/delete-account', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ user_id: sessionData.session.user.id }),
				credentials: 'include'
			});

			if (response.ok) {
				const data = await response.json();
				if (data.deleted) {
					await signOut()
				} else if (data.error) {
					validationError = data.error;
				} else {
					validationError = 'An unknown error occurred when trying to delete your account. Please try again.';
				}
			}
			else {
				validationError = 'A network error occurred when trying to delete your account. Please try again.';
			}
		}
		catch (error) {
			validationError = 'An unknown error occurred when trying to delete your account. Please try again.';
			console.error('Error deleting account:', error);
		}
		finally {
			isLoading = false;
		}
	};

	const signOut = async () => {
		isLoading = true;
		const res = await supabase.auth.signOut({});

		if (res.error === null) {
			goto('/login');
		} else if (res.error) {
			validationError = res.error.message;
		} else {
			validationError =
				'Error trying to sign out, maybe try again? If this keeps happening, please contact support.';
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
				<b class="text-emerald-100 text-lg md:text-xl max-w-2xl">
					Signed in as {email}
				</b>
				<p class="text-emerald-100 text-lg md:text-xl max-w-2xl">
					Manage your account and track your progress across challenges.
				</p>
			</div>
		</div>
	</header>

	<!-- Dashboard Content -->
	<section class="py-12">
		<!-- Statistics -->	
		 <DashboardStats />

		<!-- Account Stuff -->
		<div class="container mt-10 mx-auto max-w-4xl px-4">
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
										for="confirmation"
										class="block text-sm font-medium text-red-700 dark:text-red-300 mb-2"
									>
										To confirm, please type "Delete my account"
									</label>
									<input
										type="text"
										id="confirmation"
										name="confirmation"
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

