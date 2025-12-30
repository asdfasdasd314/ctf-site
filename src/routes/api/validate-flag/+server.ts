import { supabaseAdmin } from "$lib/server/supabaseAdmin";
import { json } from "@sveltejs/kit";

export async function POST({ request }: { request: Request }) {
    const jsonData = await request.json();
    if (jsonData.exercise_id && jsonData.flag && jsonData.user_id) {
        // First check if this user_id and exercise_id combination exists in completions
        const { data: completionData, error: completionError } = await supabaseAdmin
            .schema("public")
            .from("completions")
            .select("exercise_id")
            .eq("exercise_id", jsonData.exercise_id)
            .eq("user_id", jsonData.user_id);
        if (completionError) {
            return json({ error: completionError.message }, { status: 500 });
        }
        if (completionData.length > 0) {
            return json({ completion_exists: true }, { status: 200 });
        }

        const exercise_id = new Number(jsonData.exercise_id);
        const { data, error } = await supabaseAdmin
            .schema("public")
            .from("exercises")
            .select("flag")
            .eq("exercise_id", exercise_id);
        if (error) {
            return json({ error: error.message }, { status: 500 });
        }
        if (data.length > 0) {
            if (data[0].flag === jsonData.flag) {
                // Update the exercise completion status
                const { data: completionData, error: completionError } = await supabaseAdmin
                    .schema("public")
                    .from("completions")
                    .insert({ exercise_id: exercise_id, user_id: jsonData.user_id })
                if (completionError) {
                    return json({ error: completionError.message }, { status: 500 });
                }

                // Increment the number of solves for this exercise
                const { data: incrementData, error: incrementError } = await supabaseAdmin.schema("public").rpc("increment_exercise_count", { p_exercise_id: exercise_id });
                if (incrementError) {
                    return json({ error: incrementError.message }, { status: 500 });
                }

                return json({ flag_correct: true }, { status: 200 });
            }
            else {
                return json({ flag_correct: false }, { status: 200 });
            }
        }
        else {
            return json({ error: "Exercise not found" }, { status: 404 });
        }
    }
    return json({ error: "Invalid request" }, { status: 400 });
}