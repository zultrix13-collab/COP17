-- pgvector kNN helper for RAG retrieval.
create or replace function public.match_rag_chunks(
  p_query vector(1536),
  p_locale user_locale,
  p_k int default 6
) returns table (
  id bigint,
  source text,
  source_id text,
  content text,
  similarity float
)
language sql stable as $$
  select
    id,
    source,
    source_id,
    content,
    1 - (embedding <=> p_query) as similarity
  from public.rag_chunks
  where locale = p_locale
  order by embedding <=> p_query
  limit p_k;
$$;
