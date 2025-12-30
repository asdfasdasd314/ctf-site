import { supabaseAdmin } from '$lib/server/supabaseAdmin';
import { json } from '@sveltejs/kit';

export async function POST({ request }: { request: Request }) {
    // Obtain public_id from request body
    const jsonData = await request.json()
    if (jsonData.public_id && typeof jsonData.public_id === 'string') {
        const public_id = new Number(jsonData.public_id);
        const { data, error } = await supabaseAdmin
            .schema("vulnerable_auth_exercise")
            .from("users")
            .select("first_name,last_name")
            .eq("public_id", public_id);
        if (error) {
            return json({"error": error.message}, {status: 500});
        }
        if (data.length > 0) {
            return json({"first_name": data[0].first_name, "last_name": data[0].last_name});
        }
        return json({"error": "User not found"}, {status: 404});
    }
    return json({"error": "Invalid request"}, {status: 400});
}
