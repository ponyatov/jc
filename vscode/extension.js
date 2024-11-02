const vscode = require('vscode');

function hello() {
    vscode.window.showInformationMessage('CLI/FORTH');
}

function repl() {
    vscode.window.showInformationMessage('CLI/REPL');
}

async function activate(context) {
    console.log(activate, context);
    let hello = vscode.commands.registerCommand('cli.hello', hello);
    context.subscriptions.push(hello);
    let repl = vscode.commands.registerCommand('cli.repl', repl);
    context.subscriptions.push(repl);
}

function deactivate() {
    console.log(deactivate);
}

module.exports = {
    activate,
    deactivate,
    hello,repl
}
