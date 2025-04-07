<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let username = $state('');
	let password = $state('');
	let error = $state('');
	let isLoading = $state(true);

	onMount(async () => {
		// Check for user_id cookie
		const cookies = document.cookie.split(';');
		const userCookie = cookies.find((cookie) =>
			cookie.trim().startsWith('vulnerable_auth_user_id=')
		);

		if (!userCookie) {
			goto('/exercises/1/login');
			return;
		}

		const user_id = userCookie.split('=')[1];

		try {
			const response = await fetch('/api/exercises/1/vulnerable-retrieve-user-data', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(user_id)
			});

			const data = await response.json();

			if (data.success) {
				username = data.username;
				password = data.password;
			} else {
				error = 'Failed to load user data';
			}
		} catch (err) {
			error = 'An error occurred while loading user data';
			console.error('User data error:', err);
		} finally {
			isLoading = false;
		}
	});

	function signOut() {
		// Clear the cookie by setting it to expire in the past
		document.cookie = 'vulnerable_auth_user_id=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
		goto('/exercises/1/login');
	}
</script>

<div class="min-h-screen bg-gray-100">
	<!-- Header -->
	<header class="bg-emerald-800 shadow">
		<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
			<h1 class="text-xl font-bold text-white">Vulnerable Auth Dashboard</h1>
			<button
				onclick={signOut}
				class="px-4 py-2 bg-emerald-700 text-white rounded hover:bg-emerald-600 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 focus:ring-offset-emerald-800"
			>
				Sign Out
			</button>
		</div>
	</header>

	<!-- Content -->
	<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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
		{:else if error}
			<div class="bg-red-50 border-l-4 border-red-400 p-4 mb-6">
				<div class="flex">
					<div class="ml-3">
						<p class="text-sm text-red-700">
							{error}
						</p>
					</div>
				</div>
			</div>
		{:else}
			<div class="bg-white shadow overflow-hidden sm:rounded-lg">
				<div class="px-4 py-5 sm:px-6">
					<h2 class="text-lg leading-6 font-medium text-gray-900">User Information</h2>
					<p class="mt-1 max-w-2xl text-sm text-gray-500">Your account details</p>
				</div>
				<div class="border-t border-gray-200">
					<dl>
						<div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
							<dt class="text-sm font-medium text-gray-500">Username</dt>
							<dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{username}</dd>
						</div>
						<div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
							<dt class="text-sm font-medium text-gray-500">Password</dt>
							<dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{password}</dd>
						</div>
					</dl>
				</div>
			</div>
		{/if}
	</main>
</div>

