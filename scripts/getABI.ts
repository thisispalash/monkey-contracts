import fs from 'fs';
import path from 'path';
import { artifacts } from 'hardhat';

async function main() {
  const abiDir = path.join(__dirname, '../abis');
  if (!fs.existsSync(abiDir)) {
    fs.mkdirSync(abiDir);
  }

  // Get all build info files
  const buildInfoPaths = await artifacts.getBuildInfoPaths();
  
  for (const buildInfoPath of buildInfoPaths) {
    const buildInfo = JSON.parse(fs.readFileSync(buildInfoPath, 'utf8'));
    const output = buildInfo.output.contracts;
    
    // Extract ABIs from each contract in the build info
    for (const sourcePath in output) {
      for (const contractName in output[sourcePath]) {
        const abi = output[sourcePath][contractName].abi;
        
        fs.writeFileSync(
          path.join(abiDir, `${contractName}.json`),
          JSON.stringify(abi, null, 2)
        );
        
        console.log(`Extracted ABI for ${contractName}`);
      }
    }
  }
  
  console.log('All ABIs extracted to the abis directory');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
