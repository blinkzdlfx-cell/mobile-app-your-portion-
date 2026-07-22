import fs from 'fs'
import path from 'path'
import readline from 'readline'
import crypto from 'crypto'

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
})

function ask(query) {
  return new Promise((resolve) => rl.question(query, resolve))
}

async function main() {
  const supabaseUrl = await ask('Supabase URL: ')
  const serviceRoleKey = await ask('Supabase Service Role Key: ')
  const username = (await ask('Admin username (default: admin): ')) || 'admin'
  const password = await ask('Admin password: ')

  const env = `# Supabase config
NEXT_PUBLIC_SUPABASE_URL=${supabaseUrl}
SUPABASE_SERVICE_ROLE_KEY=${serviceRoleKey}

# Admin credentials
ADMIN_USERNAME=${username}
ADMIN_PASSWORD_HASH=${password}

# JWT secret
JWT_SECRET=${crypto.randomBytes(32).toString('hex')}
`

  fs.writeFileSync(path.join(process.cwd(), '.env'), env)
  console.log('\n✅ .env file created at', path.join(process.cwd(), '.env'))
  console.log('Run `npm run dev` to start the admin dashboard.\n')
  rl.close()
}

main()
