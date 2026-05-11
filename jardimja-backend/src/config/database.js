const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const projectRoot = path.join(__dirname, '..', '..');
const databasePath = path.join(projectRoot, 'prisma', 'database.sqlite');
const prismaClientPath = path.join(projectRoot, 'node_modules', '.prisma', 'client', 'index.js');

function runNpx(args) {
  const command = process.platform === 'win32' ? 'npx.cmd' : 'npx';
  execFileSync(command, args, {
    cwd: projectRoot,
    stdio: 'inherit'
  });
}

function prepararBancoSeNecessario() {
  if (!fs.existsSync(prismaClientPath)) {
    console.log('Gerando Prisma Client...');
    runNpx(['prisma', 'generate']);
  }

  if (!fs.existsSync(databasePath)) {
    console.log('Banco de dados nao encontrado. Rodando migrations e seed...');
    fs.mkdirSync(path.dirname(databasePath), { recursive: true });
    fs.closeSync(fs.openSync(databasePath, 'w'));
    runNpx(['prisma', 'migrate', 'dev', '--name', 'init']);
    runNpx(['prisma', 'db', 'seed']);
  }
}

module.exports = {
  prepararBancoSeNecessario
};
