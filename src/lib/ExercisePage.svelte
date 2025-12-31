<script lang="ts">
	import { onMount } from 'svelte';
	import { type Exercise, getExerciseCompletions } from './exercises';
    import { difficultiesStore, categoriesStore, exercisesStore } from './stores';
    import { supabase } from './supabaseClient';

    interface ExercisePageProps {
        exerciseId: number;
    };

    const props: ExercisePageProps = $props();

    let exercise: Exercise | null = $state(null);
    let exercises = $derived($exercisesStore);
    let difficulties = $derived($difficultiesStore);
    let categories = $derived($categoriesStore);

    let found = $state(false);
    let hints: string[] = $state([]);
    let completed: boolean = $state(false);

    onMount(async () => {
        for (const e of exercises) {
            if (e.exerciseId == props.exerciseId) {
                exercise = e;
                break;
            }
        }

        if (exercise !== null) {
            found = true;
            hints = exercise.hints;
            revealedHints = new Array(hints.length).fill(false);
        }

        const completions = await getExerciseCompletions();
        completed = completions.includes(props.exerciseId);
    });

    let flag = $state('');
    let error = $state('');
    let success = $state('');
    let isLoading = $state(false);
    let revealedHints = $state<boolean[]>([]);

    async function submitFlag(event: Event) {
        event.preventDefault();
        isLoading = true;
        error = '';
        success = '';

        const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
        if (sessionError) {
            error = 'An error occurred when trying to access the session data. Please try again.';
            console.error('Session error:', sessionError);
            return;
        }
        if (!sessionData.session?.user.id) {
            error = 'You are not logged in. Please log in to submit a flag.';
            isLoading = false;
            return;
        }
        
        try {
            const response = await fetch('/api/validate-flag', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    exercise_id: props.exerciseId,
                    flag: flag,
                    user_id: sessionData.session.user.id
                }),
                credentials: 'include'
            });

            if (response.ok) {
                const data = await response.json();
                if (data.flag_correct) {
                    success = 'Congratulations! You solved the challenge!';
                    //@ts-ignore
                    exercise.isCompleted = true;
                } else if (data.flag_correct === false) {
                    error = 'Incorrect flag';
                }
                else if (data.completion_exists) {
                    error = 'You have already completed this exercise.';
                }
                else {
                    error = 'Unknown error occurred.';
                }
            } else {
                error = 'An error occurred when trying to access the server. Please try again.';
            }
        } catch (err) {
            error = 'An error occurred while submitting the flag';
            console.error('Flag submission error:', err);
        } finally {
            isLoading = false;
        }
    }
</script>

<div class="min-h-screen bg-gray-100 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-3xl mx-auto">
        {#if exercise}
            {#if completed}
                <!-- Completed -->
                <div class="bg-green-200 rounded-lg mb-6">
                    <div class="px-4 py-5 sm:p-6">
                        <h2 class="text-green-700">Exercise completed!</h2>
                    </div>
                </div>
            {/if}
            <!-- Header -->
            <div class="bg-white shadow rounded-lg mb-6">
                <div class="px-4 py-5 sm:p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <h2 class="text-2xl font-bold text-blue-500"><a href="/exercises/{exercise.exerciseId}/start"><u>{exercise.title}</u></a></h2>
                            <div class="mt-2 flex items-center space-x-2">
                                <span class="px-2 py-1 text-xs font-medium rounded-full bg-emerald-100 text-emerald-800">
                                    {categories.find((category: { categoryId: number; }) => category.categoryId === exercise?.categoryId)?.category}
                                </span>
                                <span class="px-2 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-800">
                                    {difficulties.find((difficulty: { difficultyId: number; }) => difficulty.difficultyId === exercise?.difficultyId)?.difficulty}
                                </span>
                                <span class="px-2 py-1 text-xs font-medium rounded-full bg-purple-100 text-purple-800">
                                    {exercise.points} points
                                </span>
                            </div>
                        </div>
                        <div class="text-sm text-gray-500">
                            Solved by {exercise.solveCount} users
                        </div>
                    </div>
                </div>
            </div>

            <!-- Description -->
            <div class="bg-white shadow rounded-lg mb-6">
                <div class="px-4 py-5 sm:p-6">
                    <h2 class="text-lg font-medium text-gray-900 mb-4">Description</h2>
                    <div class="prose max-w-none">
                        {exercise.description}
                    </div>
                </div>
            </div>

            <!-- Link -->
            <div class="bg-white shadow rounded-lg mb-6">
                <div class="px-4 py-5 sm:p-6">
                    <h2 class="text-lg font-medium text-gray-900 mb-4">Link</h2>
                    <div class="prose max-w-none">
                        <a class="text-blue-500" href="/exercises/{exercise.exerciseId}/start"><u>Go solve!</u></a>
                    </div>
                </div>
            </div>

            <!-- Flag Submission -->
            <div class="bg-white shadow rounded-lg mb-6">
                <div class="px-4 py-5 sm:p-6">
                    <h2 class="text-lg font-medium text-gray-900 mb-4">Submit Flag</h2>
                    <form onsubmit={submitFlag} class="space-y-4">
                        <div>
                            <label for="flag" class="block text-sm font-medium text-gray-700">Flag</label>
                            <input
                                type="text"
                                id="flag"
                                bind:value={flag}
                                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                                placeholder="Enter the flag"
                                required
                            />
                        </div>

                        {#if error}
                            <div class="text-red-500 text-sm">{error}</div>
                        {/if}

                        {#if success}
                            <div class="text-emerald-500 text-sm">{success}</div>
                        {/if}

                        <button
                            type="submit"
                            disabled={isLoading}
                            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50"
                        >
                            {#if isLoading}
                                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                Submitting...
                            {:else}
                                Submit Flag
                            {/if}
                        </button>
                    </form>
                </div>
            </div>

            <!-- Hints -->
            <div class="bg-white shadow rounded-lg">
                <div class="px-4 py-5 sm:p-6">
                    <h2 class="text-lg font-medium text-gray-900 mb-4">Hints</h2>
                    <div class="space-y-3">
                        {#each hints as hint, i}
                            <div class="border border-gray-200 rounded-lg">
                                <button
                                    onclick={() => revealedHints[i] = !revealedHints[i]}
                                    class="w-full flex items-center justify-between px-4 py-3 text-left hover:bg-gray-50 transition-colors"
                                >
                                    <div class="flex items-center">
                                        <span class="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full bg-emerald-100 text-emerald-800 font-medium">
                                            {i + 1}
                                        </span>
                                        <span class="ml-3 font-medium text-gray-900">Hint {i + 1}</span>
                                    </div>
                                    <svg
                                        class="w-5 h-5 text-gray-500 transition-transform {revealedHints[i] ? 'rotate-180' : ''}"
                                        fill="none"
                                        stroke="currentColor"
                                        viewBox="0 0 24 24"
                                    >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                    </svg>
                                </button>
                                {#if revealedHints[i]}
                                    <div class="px-4 pb-3 pl-14">
                                        <p class="text-gray-700">{hint}</p>
                                    </div>
                                {/if}
                            </div>
                        {/each}
                    </div>
                </div>
            </div>
        {:else}
            <div class="bg-white shadow rounded-lg mb-6">
                <div class="px-4 py-5 sm:p-6">
                    <h1 class="text-2xl font-bold text-gray-900">Exercise Not Found</h1>
                </div>
            </div>
        {/if}
    </div>
</div> 