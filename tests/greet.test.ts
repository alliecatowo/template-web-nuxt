import { describe, expect, it } from 'vitest'
import { greet } from '../app/utils/greet'

describe('greet', () => {
  it('greets by name', () => {
    expect(greet(' Allie ')).toBe('Hello, Allie!')
  })

  it('rejects an empty name', () => {
    expect(() => greet('  ')).toThrow('empty')
  })
})
