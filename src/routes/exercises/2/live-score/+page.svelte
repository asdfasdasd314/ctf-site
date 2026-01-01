<script lang="ts">
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";

    onMount(async () => {
        await goto("/exercises/2/start?unauthorized=true");
    });
</script>

<div>
    <p>flag&#123l34rn_t0_cur1_7VpiCicw0z2A9oVhchxR&#125</p>
</div>