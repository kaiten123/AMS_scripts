const fs = require('fs');
const { Client } = require('ssh2');

const sshConfig = {
  host: '20.56.24.64',
  port: 22, // SSH port, default is 22
};

const localCommand = 'curl -u admin:"$(pass CQ_Admin)" -X GET http://localhost:4502/etc/reports/diskusage.html?path=/var/commerce/products'; // Replace with your desired curl command
const outputFilePath = 'output.txt'; // Replace with the desired output file path

const conn = new Client();

conn.on('ready', () => {
  conn.exec(localCommand, (err, stream) => {
    if (err) throw err;

    let outputData = '';

    stream
      .on('data', (data) => {
        outputData += data.toString();
      })
      .on('close', (code, signal) => {
        fs.writeFileSync(outputFilePath, outputData, 'utf8');
        console.log(`Command execution finished with code ${code}`);
        conn.end();
      });
  });
}).connect(sshConfig);
