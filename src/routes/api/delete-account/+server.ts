import { supabaseAdmin } from "$lib/server/supabaseAdmin";
import { json } from "@sveltejs/kit";

export async function POST({ request }: { request: Request }) {
    const jsonData = await request.json();
    if (jsonData.user_id) {
        const { data, error } = await supabaseAdmin.auth.admin.deleteUser(jsonData.user_id);
        if (error) {
            return json({ error: error.message }, { status: 500 });
        }
        return json({ deleted: true }, { status: 200 });
    }
    else {
        return json({ error: "Invalid request" }, { status: 400 });
    }
}