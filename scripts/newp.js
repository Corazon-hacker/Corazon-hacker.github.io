const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { promisify } = require('util');

const mkdir = promisify(fs.mkdir);
const writeFile = promisify(fs.writeFile);
const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);

hexo.extend.console.register('newp', 'Create new post with path (e.g., first/second/title)', {
  options: [
    { name: '--auto-complete', desc: 'Enable tab completion' }
  ]
}, async function(args) {
  const log = hexo.log || console.log;
  
  if (args.autoComplete) {
    return this.tabComplete(args);
  }
  
  const fullPath = args._[0];
  if (!fullPath) {
    log.error('Usage: hexo newp <path/levels/title>');
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
  
  // 创建目录结构 - 确保文件夹和文件在同一层级
  const baseDir = path.join(hexo.source_dir, '_posts', category);
  const folderPath = path.join(baseDir, folderName);
  const filePath = path.join(baseDir, fileName);
  
  try {
    // 创建文件夹（用于存放资源）
    await mkdir(folderPath, { recursive: true });
    
    // 使用模板文件
    const templatePath = path.join(hexo.scaffold_dir, 'post.md');
    let templateContent;
    
    try {
      templateContent = await readFile(templatePath, 'utf8');
    } catch (e) {
      // 如果模板文件不存在，使用默认模板
      templateContent = [
        '---',
        'title: {{ title }}',
        'date: {{ date }}',
        'categories:',
        'tags:',
        '- private',
        'description: 声明：文章中涉及的程序(方法)可能带有攻击性，仅供安全研究与教学之用，读者将其信息做其他用途，由用户承担全部法律及连带责任，文章作者不承担任何法律及连带责任。',
        'top:',
        'comments: true',
        '---'
      ].join('\n');
    }
    
    // 替换模板中的标题
    const content = templateContent
      .replace(/{{ title }}/g, folderName)
      .replace(/{{ date }}/g, new Date().toISOString());
    
    // 创建 Markdown 文件
    await writeFile(filePath, content);
    
    log.info(`Created folder: ${folderPath}`);
    log.info(`Created file: ${filePath}`);
  } catch (error) {
    log.error(`Error creating post: ${error.message}`);
  }
});

// Tab 补全逻辑保持不变
hexo.extend.console.tabComplete = async function(args) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    completer: async (line) => {
      const partial = line.trim().replace(/\\/g, '/');
      const baseDir = path.join(hexo.source_dir, '_posts');
      
      const matches = await this.findMatches(baseDir, partial);
      
      if (matches.length === 1) {
        const completed = matches[0] + '/';
        return [[completed], completed];
      } else if (matches.length > 1) {
        console.log('\n' + matches.join('\n'));
      }
      return [matches, line];
    }
  });

  rl.question('Enter post path: ', (line) => {
    if (line.trim()) {
      hexo.call('newp', { _: [line.trim()] }, () => {
        rl.close();
      });
    } else {
      rl.close();
    }
  });
};

// 路径匹配函数保持不变
hexo.extend.console.findMatches = async function(baseDir, partialPath) {
  const parts = partialPath.split('/');
  let currentDir = baseDir;
  let existingPath = [];
  
  for (const part of parts.slice(0, -1)) {
    if (!part) continue;
    
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
  
  const lastPartial = parts[parts.length - 1] || '';
  let dirContents = [];
  
  try {
    dirContents = await readdir(currentDir, { withFileTypes: true });
  } catch (e) {
    return [];
  }
  
  return dirContents
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name)
    .filter(name => name.startsWith(lastPartial))
    .map(name => [...existingPath, name].join('/'));
};