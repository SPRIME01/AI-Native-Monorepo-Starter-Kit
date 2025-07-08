# Supabase Shared Data-Access Library

This library provides a single, reusable Supabase client for all domains and apps in the monorepo. It is intended to be used as the only point of integration with Supabase from business logic or API layers.

- Set `SUPABASE_URL` and `SUPABASE_KEY` in your environment.
- Import and use `supabase` from `libs.shared.data-access.supabase.client`.
