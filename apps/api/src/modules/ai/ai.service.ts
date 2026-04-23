import Anthropic from '@anthropic-ai/sdk';
import { Injectable, Logger } from '@nestjs/common';
import { EmbeddingsService } from './embeddings.service';

const SYSTEM_PROMPT = `You are the COP17 event assistant. COP17 is the 17th UNCCD Conference
of the Parties in Ulaanbaatar, Mongolia, August 17–28, 2026.

Main venues:
- State Palace (Төрийн ордон) — main plenary, opening/closing ceremonies
- Exhibition Center (Үзэсгэлэнгийн төв) — technical summits, side events
All venues are within a 15-minute radius of Ulaanbaatar city centre.

Answer concisely using ONLY the context chunks provided below the user question.
If the context does not contain the answer, say so in the user's language and suggest
visiting the Info Desk at the State Palace.

Respond in the SAME language the user wrote in (Mongolian or English).
Keep answers under 120 words. Quote exact times, halls, and prices from context when present.`;

@Injectable()
export class AiService {
  private readonly log = new Logger(AiService.name);
  private readonly client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY ?? '' });

  constructor(private readonly embeddings: EmbeddingsService) {}

  async chat(message: string, locale: 'mn' | 'en') {
    const chunks = await this.embeddings.search(message, locale);
    const context = chunks.map((c, i) => `[${i + 1}] ${c}`).join('\n---\n');

    const res = await this.client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 400,
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: 'user',
          content: `<context>\n${context}\n</context>\n\nUser question: ${message}`,
        },
      ],
    });

    const text = res.content
      .filter((b): b is Anthropic.TextBlock => b.type === 'text')
      .map((b) => b.text)
      .join('\n');

    return { answer: text, sources: chunks.length, usage: res.usage };
  }
}
