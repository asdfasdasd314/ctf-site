import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_URL } from '$env/static/public';
import { SUPABASE_SECRET_KEY } from '$env/static/private';

export const supabaseAdmin = createClient(
    PUBLIC_SUPABASE_URL,
    SUPABASE_SECRET_KEY
);

export async function clearExpiredUsers() {
    // Clear users if they have existed for longer than 15 minutes AND are not "seeded"

    const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000).toISOString();

    const { data, error } = await supabaseAdmin
        .schema("vulnerable_auth_exercise")
        .from("users")
        .delete()
        .lt('created_at', fifteenMinutesAgo)
        .neq('seeded', true);
    if (error) {
        throw new Error(error.message);
    }

    return { success: true };
}

export async function resetPublicIdSequence() {
    // Call Supabase function
    const { data, error } = await supabaseAdmin
        .schema("vulnerable_auth_exercise")
        .rpc("reset_public_id_seq");
    if (error) {
        throw new Error(error.message);
    }
    return { success: true };
}