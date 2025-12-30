<script lang="ts">
	import { goto } from '$app/navigation';

	let error = $state('');
	let isLoading = $state(false);

	async function handleLogin(event: Event) {
		event.preventDefault();
		const form = event.target as HTMLFormElement;
		const formData = new FormData(form);
		const first_name = formData.get('first_name') as string;
		const last_name = formData.get('last_name') as string;

		if (!first_name || !last_name) {
			error = 'Please enter both first name and last name';
			return;
		}

		isLoading = true;
		error = '';

		try {
			const response = await fetch('/api/exercises/1/vulnerable-login', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ first_name, last_name })
			});

			if (response.ok) {
				const data = await response.json();
				if (data.public_id) {
					// Clear old cookie
					document.cookie = 'vuln_auth_public_id=; max-age=0;';

					// Set cookie with public_id
					document.cookie = `vuln_auth_public_id=${data.public_id};`;
					goto('/exercises/1/dashboard');
				}
				else {
					error = data.error || 'Unknown error occurred.';
				}
			}
			else {
				error = 'An error processing the request occurred. Please try again.';
				console.error('Login error:', response);
			}
		} catch (err) {
			error = 'An error occurred when trying to access the server. Please try again.';
			console.error('Login error:', err);
		} finally {
			isLoading = false;
		}
	}
</script>

<div class="min-h-screen bg-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
	<div class="max-w-md w-full space-y-8">
		<div>
			<h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
				Sign in to your account
			</h2>
		</div>
		<form class="mt-8 space-y-6" onsubmit={handleLogin}>
			<div class="rounded-md shadow-sm -space-y-px">
				<div>
					<label for="first_name" class="sr-only">First Name</label>
					<input
						id="first_name"
						name="first_name"
						type="text"
						required
						class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 focus:z-10 sm:text-sm"
						placeholder="First Name"
					/>
				</div>
				<div>
					<label for="last_name" class="sr-only">Last Name</label>
					<input
						id="last_name"
						name="last_name"
						type="text"
						required
						class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 focus:z-10 sm:text-sm"
						placeholder="Last Name"
					/>
				</div>
			</div>

			{#if error}
				<div class="text-red-500 text-sm text-center">{error}</div>
			{/if}

			<div>
				<button
					type="submit"
					disabled={isLoading}
					class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50"
				>
					{#if isLoading}
						<svg
							class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
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
					{/if}
					Sign in
				</button>
			</div>
		</form>

		<div class="text-center">
			<a href="/exercises/1/signup" class="text-emerald-600 hover:text-emerald-500">
				Don't have an account? Sign up
			</a>
		</div>
	</div>
</div>

