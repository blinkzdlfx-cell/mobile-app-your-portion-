const bcrypt = require('bcryptjs');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question('Supabase URL: ', (supabaseUrl) => {
  rl.question('Supabase Service Role Key: ', (serviceRoleKey) => {
    rl.question('Admin username (default: admin): ', (username) => {
      rl.question('Admin password: ', async (password) => {
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(password, salt);

        const envContent = `# Supabase config
SUPABASE_URL=${supabaseUrl}
SUPABASE_SERVICE_ROLE_KEY=${serviceRoleKey}

# Admin credentials
ADMIN_USERNAME=${username || 'admin'}
ADMIN_PASSWORD_HASH=${hash}

# JWT secret for admin sessions
JWT_SECRET=${require('crypto').randomBytes(32).toString('hex')}
`;

        fs.writeFileSync(path.join(__dirname, '.env'), envContent);
        console.log('\n.env file created successfully!');
        console.log('Run `npm start` to launch the admin server.\n');
        rl.close();
      });
    });
  });
});
