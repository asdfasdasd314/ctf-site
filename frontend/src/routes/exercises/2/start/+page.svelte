<script lang="ts">
    import { page } from "$app/state";
    import { onMount } from "svelte";

    let authorized = $state(true);

    onMount(() => {
        if (page.url.toString().includes("unauthorized")) {
            authorized = false;
        }
    });

    const homeTeam = {
        name: "New York Pioneers",
        record: "12-5",
        points: 451
    };

    const awayTeam = {
        name: "Phoenix Pioneers",
        record: "11-6",
        points: 450
    };
</script>

<div class="min-h-screen bg-gray-100 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-4xl mx-auto">
        <!-- Game Header -->
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">Football Playoffs 2024</h1>
            <div class="text-xl text-gray-600">
                <p>Super Game III</p>
                <p>Albuquerque, NM</p>
                <p>February 11, 2024 - 6:30 PM EST</p>
            </div>
        </div>

        <!-- Game Scoreboard -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
            <div class="grid grid-cols-2 gap-8">
                <!-- Away Team -->
                <div class="text-center">
                    <h2 class="text-2xl font-bold text-gray-900">{awayTeam.name}</h2>
                    <p class="text-gray-600">Record: {awayTeam.record}</p>
                    <p class="text-gray-600">Season Points: {awayTeam.points}</p>
                </div>

                <!-- VS -->
                <div class="flex items-center justify-center">
                    <div class="text-4xl font-bold text-gray-900">VS</div>
                </div>

                <!-- Home Team -->
                <div class="text-center">
                    <h2 class="text-2xl font-bold text-gray-900">{homeTeam.name}</h2>
                    <p class="text-gray-600">Record: {homeTeam.record}</p>
                    <p class="text-gray-600">Season Points: {homeTeam.points}</p>
                </div>
            </div>
        </div>

        <!-- Game Info -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
            <h2 class="text-2xl font-semibold text-gray-800 mb-4">Game Information</h2>
            <div class="grid grid-cols-2 gap-4 text-gray-600">
                <div>
                    <p class="font-medium">Broadcast:</p>
                    <p>CBS, ESPN, NFL Network</p>
                </div>
                <div>
                    <p class="font-medium">Weather:</p>
                    <p>Indoor Stadium</p>
                </div>
                <div>
                    <p class="font-medium">Referee:</p>
                    <p>John Doe</p>
                </div>
                <div>
                    <p class="font-medium">Stadium Capacity:</p>
                    <p>12,345</p>
                </div>
            </div>
        </div>

        <!-- Live Score Link -->
        <div class="text-center">
            <a href="/exercises/2/live-score" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500">
                View Live Score
                <svg class="ml-2 -mr-1 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
            </a>
        </div>

        {#if !authorized}
            <div class="mt-4 text-center text-red-600">
                <p>Unable to access live scores! Please upgrade your account.</p>
            </div>
        {/if}
    </div>
</div>
