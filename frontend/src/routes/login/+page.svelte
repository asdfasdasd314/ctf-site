<script lang="ts">
    import * as auth from "$lib/userAuth";
    import { onMount } from 'svelte';
    import { goto } from "$app/navigation";
    import { fly, fade } from 'svelte/transition';

    onMount(async () => {
        if (await auth.checkAuth()) {
            await goto("/dashboard");
        }
    });

    let isLoading = $state(false);
    let loginError = $state('');
    const handleSubmit = async (event: SubmitEvent) => {
        event.preventDefault();
        const form = event.target as HTMLFormElement;
        const formData = new FormData(form);
        const username = formData.get('username') as string;
        const password = formData.get('password') as string;

        if (!username || !password) {
            loginError = "Please enter both username and password";
            return;
        }

        isLoading = true;
        const res = await fetch("/api/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ username, password })
        });

        if (res.status === 200 && await auth.checkAuth()) {
            await goto("/dashboard");
        }
        else if (res.status === 401) {
            loginError = "Invalid username or password";
        }
        else {
            loginError = "Error trying to login, maybe try again? If this keeps happening, please contact support.";
        }
        isLoading = false;
    }
</script>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100">
    <!-- Header -->
    <header class="bg-gradient-to-r from-emerald-600 to-cyan-600 py-16 px-4">
        <div class="container mx-auto max-w-6xl">
            <div in:fly={{ y: -20, duration: 800 }}>
                <h1 class="text-4xl md:text-5xl font-bold text-white mb-4">Welcome Back</h1>
                <p class="text-emerald-100 text-lg md:text-xl max-w-2xl">
                    Sign in to your account to continue solving challenges and tracking your progress.
                </p>
            </div>
        </div>
    </header>

    <!-- Login Form -->
    <section class="py-12">
        <div class="container mx-auto max-w-md px-4">
            <div 
                class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8"
                in:fade={{ duration: 500 }}
            >
                <form onsubmit={handleSubmit} class="space-y-6">
                    <!-- Username -->
                    <div>
                        <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Username
                        </label>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            placeholder="Enter your username"
                            class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
                            required
                        />
                    </div>

                    <!-- Password -->
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Password
                        </label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 dark:focus:ring-emerald-400 dark:focus:border-emerald-400 outline-none transition-all"
                            required
                        />
                    </div>

                    <!-- Error Message -->
                    {#if loginError}
                        <div class="bg-red-50 dark:bg-red-900/50 text-red-700 dark:text-red-200 p-4 rounded-lg text-sm">
                            {loginError}
                        </div>
                    {/if}

                    <!-- Submit Button -->
                    <button
                        type="submit"
                        class="w-full px-4 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-medium rounded-lg transition-colors duration-300 flex items-center justify-center"
                        disabled={isLoading}
                    >
                        {#if isLoading}
                            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            Signing in...
                        {:else}
                            Sign In
                        {/if}
                    </button>
                </form>

                <!-- Sign Up Link -->
                <div class="mt-6 text-center">
                    <p class="text-sm text-gray-600 dark:text-gray-400">
                        Don't have an account?
                        <a href="/sign-up" class="text-emerald-500 hover:text-emerald-600 font-medium">
                            Sign up
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </section>
</div>

<style>
</style>