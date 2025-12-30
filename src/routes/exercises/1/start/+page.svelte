<script lang="ts">
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";

    onMount(async () => {
        await goto("/exercises/1/signup");
    })
</script>

<h1>Go to /exercises/1/signup</h1>