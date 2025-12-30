<script lang="ts">
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";

    onMount(async () => {
        await goto("/exercises/2/start?unauthorized=true");
    });
</script>

<div>
    <p>flag&#123l34rn_t0_cur1_fvSUQMQUJ0gVF547&#125</p>
</div>