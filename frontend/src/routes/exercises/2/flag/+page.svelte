<script lang="ts">
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";

    onMount(async () => {
        await goto("/exercises/2/start");
    })
</script>

<div>
    <h1>Flag</h1>
</div>