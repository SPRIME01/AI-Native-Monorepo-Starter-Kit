import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { VectorRecord } from "./supabase_vector_types";

export class SupabaseVectorAdapter {
  private client: SupabaseClient;

  constructor(url?: string, key?: string) {
    this.client = createClient(
      url || process.env.NX_SUPABASE_URL!,
      key || process.env.NX_SUPABASE_SERVICE_ROLE_KEY!
    );
  }

  async upsert(records: VectorRecord[]): Promise<void> {
    await this.client.from("vectors").upsert(records);
  }

  async query(
    queryEmbedding: number[],
    topK: number = 5
  ): Promise<VectorRecord[]> {
    // Placeholder: Use a custom RPC or SQL function for vector search
    const { data } = await this.client.rpc("vector_search", {
      query_embedding: queryEmbedding,
      top_k: topK,
    });
    return data as VectorRecord[];
  }

  async delete(ids: string[]): Promise<void> {
    for (const id of ids) {
      await this.client.from("vectors").delete().eq("id", id);
    }
  }
}
