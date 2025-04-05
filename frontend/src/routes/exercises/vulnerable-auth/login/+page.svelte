<script lang="ts">
    import { goto } from '$app/navigation';
    
    let error = '';
    let isLoading = false;
    
    async function handleLogin(event: Event) {
        const form = event.target as HTMLFormElement;
        const formData = new FormData(form);
        const username = formData.get('username') as string;
        const password = formData.get('password') as string;
        
        if (!username || !password) {
            error = 'Please enter both username and password';
            return;
        }
        
        isLoading = true;
        error = '';
        
        try {
            const response = await fetch('/api/exercises/vulnerable-auth/vulnerable-login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, password })
            });
            
            if (response.status === 200) {
                const data = await response.json();
                if (data.user_id) {
                    // Set cookie with user_id
                    document.cookie = `vulnerable_auth_user_id=${data.user_id}; path=/`;
                    goto('/exercises/vulnerable-auth');
                }
            }
            else {
                error = 'Invalid username or password';
            }
        } catch (err) {
            error = 'An error occurred. Please try again.';
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
        <form class="mt-8 space-y-6" on:submit|preventDefault={handleLogin}>
            <div class="rounded-md shadow-sm -space-y-px">
                <div>
                    <label for="username" class="sr-only">Username</label>
                    <input
                        id="username"
                        name="username"
                        type="text"
                        required
                        class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 focus:z-10 sm:text-sm"
                        placeholder="Username"
                    />
                </div>
                <div>
                    <label for="password" class="sr-only">Password</label>
                    <input
                        id="password"
                        name="password"
                        type="password"
                        required
                        class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 focus:z-10 sm:text-sm"
                        placeholder="Password"
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
                        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                    {/if}
                    Sign in
                </button>
            </div>
        </form>
        
        <div class="text-center">
            <a href="/exercises/vulnerable-auth/signup" class="text-emerald-600 hover:text-emerald-500">
                Don't have an account? Sign up
            </a>
        </div>
    </div>
</div>