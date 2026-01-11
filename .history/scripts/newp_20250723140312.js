const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { promisify } = require('util');

const mkdir = promisify(fs.mkdir);
const writeFile = promisify(fs.writeFile);
const readdir = promisify(fs.readdir);

hexo.extend.console.register('newp', 'Create new post with path (e.g., first/second/title)', {
  options: [
    { name: '--auto-complete', desc: 'Enable tab completion' }
  ]
}, async function(args) {
  // 使用 hexo.log 替代 this.log
  const log = hexo.log || console.log;
  
  if (args.autoComplete) {
    return this.tabComplete(args);
  }
  
  const fullPath = args._[0];
  if (!fullPath) {
    log('Usage: hexo newp <path/levels/title>');
    return;
  }

  // 处理 Windows 路径分隔符问题
  const normalizedPath = fullPath.replace(/\\/g, '/');
  const parts = normalizedPath.split('/');
  const title = parts.pop();
  const category = parts.join('/');
  const lastDir = parts[parts.length - 1] || '';

  // 生成文件夹名和文件名
  const folderName = `【${lastDir}】${title}`;
  const fileName = `${folderName}.md`;
  
  // 创建目录结构
  const postDir = path.join(hexo.source_dir, '_posts', category, folderName);
  const filePath = path.join(postDir, fileName);
  
  try {
    await mkdir(postDir, { recursive: true });
    
    // 生成文件内容
    const content = [
      '---',
      `title: ${folderName}`,
      `date: ${new Date().toISOString()}`,
      'tags:',
      'categories:',
      `  - ${category.replace(/\//g, '/')}`,
      '---',
      ''
    ].join('\n');
    
    await writeFile(filePath, content);
    log.info(`Created: ${filePath}`);
  } catch (error) {
    log.error(`Error creating post: ${error.message}`);
  }
});

// Tab 补全逻辑
hexo.extend.console.tabComplete = async function(args) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    completer: async (line) => {
      const partial = line.trim().replace(/\\/g, '/'); // 处理 Windows 路径
      const baseDir = path.join(hexo.source_dir, '_posts');
      
      // 获取匹配的路径列表
      const matches = await this.findMatches(baseDir, partial);
      
      if (matches.length === 1) {
        // 唯一匹配时自动补全
        const completed = matches[0] + '/';
        return [[completed], completed];
      } else if (matches.length > 1) {
        // 多个匹配时显示列表
        console.log('\n' + matches.join('\n'));
      }
      return [matches, line];
    }
  });

  rl.question('Enter post path: ', (line) => {
    if (line.trim()) {
      // 使用 hexo.call 替代 this.call
      hexo.call('newp', { _: [line.trim()] }, () => {
        rl.close();
      });
    } else {
      rl.close();
    }
  });
};

// 路径匹配函数
hexo.extend.console.findMatches = async function(baseDir, partialPath) {
  const parts = partialPath.split('/');
  let currentDir = baseDir;
  let existingPath = [];
  
  // 遍历已存在的路径部分
  for (const part of parts.slice(0, -1)) {
    if (!part) continue; // 跳过空部分
    
    const testDir = path.join(currentDir, part);
    try {
      if (!fs.existsSync(testDir)) break;
      const stat = fs.statSync(testDir);
      if (!stat.isDirectory()) break;
      
      currentDir = testDir;
      existingPath.push(part);
    } catch (e) {
      break;
    }
  }
  
  // 获取补全建议
  const lastPartial = parts[parts.length - 1] || '';
  let dirContents = [];
  
  try {
    dirContents = await readdir(currentDir, { withFileTypes: true });
  } catch (e) {
    return [];
  }
  
  const suggestions = dirContents
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name)
    .filter(name => name.startsWith(lastPartial))
    .map(name => [...existingPath, name].join('/'));
  
  return suggestions;
};