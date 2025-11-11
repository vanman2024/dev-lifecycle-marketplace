import { render, screen, userEvent } from '../utils/test-utils'
import { ComponentName } from '@/components/ComponentName'

describe('ComponentName', () => {
  it('renders correctly', () => {
    render(<ComponentName />)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })

  it('handles user interaction', async () => {
    const handleClick = jest.fn()
    render(<ComponentName onClick={handleClick} />)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('displays correct text', () => {
    render(<ComponentName text="Hello World" />)
    expect(screen.getByText('Hello World')).toBeInTheDocument()
  })

  it('handles async operations', async () => {
    render(<ComponentName />)

    // Wait for async operation
    const result = await screen.findByText(/success/i)
    expect(result).toBeInTheDocument()
  })

  it('handles error states', async () => {
    render(<ComponentName shouldError />)

    const error = await screen.findByRole('alert')
    expect(error).toHaveTextContent(/error/i)
  })
})
