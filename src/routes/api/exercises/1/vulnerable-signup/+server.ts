import { clearExpiredUsers, resetPublicIdSequence, supabaseAdmin } from "$lib/server/supabaseAdmin";
import { error, json } from "@sveltejs/kit";

export async function POST({ request }: { request: Request }) {
    // TODO: Implement this endpoint

    try {
        const jsonData = await request.json();

        if (jsonData.first_name && jsonData.last_name) {

            // Fix this, want to also obtain the public_id and return it
            try {
                const { data, error } = await supabaseAdmin
                    .schema("vulnerable_auth_exercise")
                    .from("users")
                    .insert({"first_name": jsonData.first_name, "last_name": jsonData.last_name})
                    .select("public_id");
                if (error) {
                    return json({"error": error.message}, {status: 500});
                }
                if (data.length > 0) {
                    // Don't need any annoying Cron jobs, just do it here
                    try {
                        if (data[0].public_id > 2500) {
                            await resetPublicIdSequence();
                        }
                        if (data[0].public_id % 100 === 0) {
                            await clearExpiredUsers();
                        }
                    } catch (error: any) {
                        console.error("Cron jobs did not work as expected");
                        console.error(error);
                    }
                    return json({"public_id": data[0].public_id}, {status: 200});
                }
                return json({"error": "User not created"}, {status: 500});
            }
            catch (error: any) {
                return json({"error": error.message}, {status: 500});
            }
        }
        return json({"error": "Invalid request"}, {status: 400});
    }
    catch (error: any) {
        return json({"error": error.message}, {status: 500});
    }
}
