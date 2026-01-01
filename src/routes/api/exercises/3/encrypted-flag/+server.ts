import { json } from '@sveltejs/kit';
import { supabaseAdmin } from '$lib/server/supabaseAdmin';

async function encodeFlag(flag: string) {
    // 1. Encode plaintext
    const plaintextArray = new TextEncoder().encode(flag);

    // 2. Create / import key (must match decrypt key)
    const keyArray = crypto.getRandomValues(new Uint8Array(32)); // 256-bit key

    const cryptoKey = await crypto.subtle.importKey(
      'raw',
      keyArray,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt']
    );

    // 3. Generate IV (12 bytes is REQUIRED for AES-GCM best practice)
    const ivArray = crypto.getRandomValues(new Uint8Array(12));

    // 4. Encrypt
    const encryptedCombined = new Uint8Array(
      await crypto.subtle.encrypt(
        {
          name: 'AES-GCM',
          iv: ivArray,
          tagLength: 128
        },
        cryptoKey,
        plaintextArray
      )
    );

    // 5. Split ciphertext and auth tag
    const TAG_LENGTH_BYTES = 16;

    const encryptedArray = encryptedCombined.slice(
      0,
      encryptedCombined.length - TAG_LENGTH_BYTES
    );

    const authTagArray = encryptedCombined.slice(
      encryptedCombined.length - TAG_LENGTH_BYTES
    );

    return {
        encryptedArray: encryptedArray.toString(),
        authTagArray: authTagArray.toString(),
        ivArray: ivArray.toString(),
        keyArray: keyArray.toString()
    }
}

export async function GET() {
    const { data, error } = await supabaseAdmin.schema("public").from("exercises").select("flag").eq("exercise_id", 3);
    if (error) {
        return json({ error: error.message }, { status: 500 });
    }
    if (data.length === 0) {
        return json({ error: "Internal server error" }, { status: 500 });
    }
    const flag = data[0].flag as string;
    const encodedFlag = await encodeFlag(flag);
    return json({
        encryptedArray: encodedFlag.encryptedArray,
        authTagArray: encodedFlag.authTagArray,
        ivArray: encodedFlag.ivArray,
        keyArray: encodedFlag.keyArray
    });
}