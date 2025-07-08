import { expect, test } from "@playwright/test";

const SUPABASE_URL = process.env.NX_SUPABASE_URL || "http://localhost:54321";
const SUPABASE_KEY = process.env.NX_SUPABASE_ANON_KEY || "";

// Example: Test vector upsert and search via Supabase REST API

test.describe("Supabase Vector DB End-to-End", () => {
  let vectorId: string;
  const embedding = Array(1536).fill(0.5); // Dummy embedding
  const metadata = { user_id: "test-user", label: "test" };

  test("Upsert vector", async ({ request }) => {
    const res = await request.post(`${SUPABASE_URL}/rest/v1/vectors`, {
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=representation",
      },
      data: [
        {
          id: "e2e-test-id",
          embedding,
          metadata,
        },
      ],
    });
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(body[0].id).toBe("e2e-test-id");
    vectorId = body[0].id;
  });

  test("Query vector", async ({ request }) => {
    // This assumes a custom RPC or REST endpoint for vector similarity search
    // Replace with your actual endpoint if different
    const res = await request.post(
      `${SUPABASE_URL}/rest/v1/rpc/vector_search`,
      {
        headers: {
          apikey: SUPABASE_KEY,
          Authorization: `Bearer ${SUPABASE_KEY}`,
          "Content-Type": "application/json",
        },
        data: {
          query_embedding: embedding,
          top_k: 1,
        },
      }
    );
    expect(res.ok()).toBeTruthy();
    const body = await res.json();
    expect(body.length).toBeGreaterThan(0);
    expect(body[0].id).toBe("e2e-test-id");
  });

  test.afterAll(async ({ request }) => {
    // Clean up test vector
    await request.delete(`${SUPABASE_URL}/rest/v1/vectors?id=eq.e2e-test-id`, {
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
      },
    });
  });
});
