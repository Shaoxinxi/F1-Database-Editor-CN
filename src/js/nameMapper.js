/**
 * 中文名称映射管理器
 * 用于将英文车队名称、车手姓名等转换为中文
 */

// 中文名称映射数据
let chineseNames = null;

// 基础映射（fallback，如果JSON加载失败）
const fallbackNames = {
  teams: {
    'Ferrari': '法拉利车队',
    'Red Bull': '红牛车队',
    'Red Bull Racing': '红牛车队',
    'Mercedes': '梅赛德斯车队',
    'McLaren': '迈凯伦车队',
    'Williams': '威廉姆斯车队',
    'Alpine': '阿尔派车队',
    'Aston Martin': '阿斯顿·马丁车队',
    'Haas': '哈斯车队',
    'Sauber': '索伯车队',
    'RB': 'RB车队',
    'AlphaTauri': '阿尔法托利车队',
    'Alfa Romeo': '阿尔法·罗密欧车队'
  },
  drivers: {
    'Verstappen': '维斯塔潘',
    'Hamilton': '汉密尔顿',
    'Leclerc': '勒克莱尔',
    'Norris': '诺里斯',
    'Perez': '佩雷斯',
    'Russell': '拉塞尔',
    'Sainz': '塞恩斯',
    'Alonso': '阿隆索',
    'Stroll': '斯特罗尔',
    'Piastri': '皮亚斯特里',
    'Gasly': '加斯利',
    'Ocon': '奥康',
    'Albon': '阿尔本',
    'Sargeant': '萨金特',
    'Hulkenberg': '霍肯伯格',
    'Magnussen': '马格努森',
    'Bottas': '博塔斯',
    'Zhou': '周冠宇',
    'Tsunoda': '角田裕毅',
    'Ricciardo': '里卡多',
    'Antonelli': '安东内利',
    'Doohan': '杜汉',
    'Lawson': '劳森',
    'Colapinto': '科拉平托',
    'Bearman': '贝尔曼',
    'Bortoleto': '博托莱托',
    'Hadjar': '哈贾尔'
  }
};

/**
 * 加载中文名称映射文件
 */
export async function loadChineseNames() {
  if (chineseNames) {
    return chineseNames; // 已经加载过
  }

  try {
    const response = await fetch('data/zh_CN_names.json');
    if (response.ok) {
      chineseNames = await response.json();
      console.log('✅ 中文名称映射加载成功');
      return chineseNames;
    } else {
      console.warn('⚠️ 中文名称映射文件加载失败，使用备用映射');
      chineseNames = fallbackNames;
      return chineseNames;
    }
  } catch (error) {
    console.error('❌ 加载中文名称映射失败:', error);
    chineseNames = fallbackNames;
    return chineseNames;
  }
}

/**
 * 获取车队的中文名称
 * @param {string} englishName - 英文车队名称
 * @returns {string} 中文车队名称
 */
export function getTeamName(englishName) {
  if (!chineseNames) {
    return englishName; // 还未加载，返回原名
  }

  // 尝试精确匹配
  if (chineseNames.teams[englishName]) {
    return chineseNames.teams[englishName];
  }

  // 尝试忽略大小写匹配
  const lowerName = englishName.toLowerCase();
  for (const [key, value] of Object.entries(chineseNames.teams)) {
    if (key.toLowerCase() === lowerName) {
      return value;
    }
  }

  // 尝试部分匹配
  for (const [key, value] of Object.entries(chineseNames.teams)) {
    if (lowerName.includes(key.toLowerCase()) || key.toLowerCase().includes(lowerName)) {
      return value;
    }
  }

  // 使用备用映射
  if (fallbackNames.teams[englishName]) {
    return fallbackNames.teams[englishName];
  }

  // 都没有匹配，返回原名
  return englishName;
}

/**
 * 获取车手的中文姓名
 * @param {string} englishName - 英文车手姓名（姓氏）
 * @returns {string} 中文车手姓名
 */
export function getDriverName(englishName) {
  if (!chineseNames) {
    return englishName;
  }

  // 尝试精确匹配
  if (chineseNames.drivers[englishName]) {
    return chineseNames.drivers[englishName];
  }

  // 尝试忽略大小写匹配
  const lowerName = englishName.toLowerCase();
  for (const [key, value] of Object.entries(chineseNames.drivers)) {
    if (key.toLowerCase() === lowerName) {
      return value;
    }
  }

  // 尝试部分匹配
  for (const [key, value] of Object.entries(chineseNames.drivers)) {
    if (lowerName.includes(key.toLowerCase()) || key.toLowerCase().includes(lowerName)) {
      return value;
    }
  }

  // 使用备用映射
  if (fallbackNames.drivers[englishName]) {
    return fallbackNames.drivers[englishName];
  }

  // 都没有匹配，返回原名
  return englishName;
}

/**
 * 获取工作人员的中文职位名称
 * @param {string} englishTitle - 英文职位名称
 * @returns {string} 中文职位名称
 */
export function getStaffTitle(englishTitle) {
  if (!chineseNames) {
    return englishTitle;
  }

  return chineseNames.staff[englishTitle] || 
         fallbackNames.staff?.[englishTitle] || 
         englishTitle;
}

/**
 * 获取赛道的中文名称
 * @param {string} englishName - 英文赛道名称
 * @returns {string} 中文赛道名称
 */
export function getTrackName(englishName) {
  if (!chineseNames) {
    return englishName;
  }

  return chineseNames.tracks[englishName] || englishName;
}

/**
 * 获取比赛阶段的中文名称
 * @param {string} englishName - 英文比赛阶段名称
 * @returns {string} 中文比赛阶段名称
 */
export function getSessionName(englishName) {
  if (!chineseNames) {
    return englishName;
  }

  return chineseNames.sessions[englishName] || englishName;
}

/**
 * 通用名称转换函数
 * @param {string} englishName - 英文名称
 * @param {string} type - 类型：'team', 'driver', 'staff', 'track', 'session'
 * @returns {string} 中文名称
 */
export function getChineseName(englishName, type = 'driver') {
  switch (type) {
    case 'team':
      return getTeamName(englishName);
    case 'driver':
      return getDriverName(englishName);
    case 'staff':
      return getStaffTitle(englishName);
    case 'track':
      return getTrackName(englishName);
    case 'session':
      return getSessionName(englishName);
    default:
      return englishName;
  }
}

/**
 * 批量转换文本中的名称
 * @param {string} text - 原始文本
 * @param {Array} names - 需要转换的名称列表
 * @param {string} type - 类型
 * @returns {string} 转换后的文本
 */
export function translateNamesInText(text, names, type = 'driver') {
  let result = text;
  for (const name of names) {
    const chineseName = getChineseName(name, type);
    if (chineseName !== name) {
      result = result.split(name).join(chineseName);
    }
  }
  return result;
}

// 自动加载映射
loadChineseNames();
