import { supabaseAdmin } from "$lib/server/supabaseAdmin";
import { json } from "@sveltejs/kit";

export async function POST({ request }: { request: Request }) { 
    const jsonData = await request.json();
    if (jsonData.first_name && jsonData.last_name) {
        const { data, error } = await supabaseAdmin
            .schema("vulnerable_auth_exercise")
            .from("users")
            .select("public_id")
            .eq("first_name", jsonData.first_name)
            .eq("last_name", jsonData.last_name);

        if (error) {
            return json({"error": error.message}, {status: 500});
        }
        if (data.length > 0) {
            // Add leading 0s to public_id
            if (data[0].public_id > 9_999_999_999) {
                return json({"error": "ID is too large"}, {status: 500});
            }
            const id = new String(data[0].public_id);

            const modified = "0000000000".slice(0, 10 - id.length) + id;

            return json({"public_id": modified}, {status: 200});
        }
        return json({"error": "User not found"}, {status: 200});
    }
    return json({"error": "Invalid request"}, {status: 400});
}
