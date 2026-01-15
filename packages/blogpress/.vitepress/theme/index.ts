import type { EnhanceAppContext } from 'vitepress'
import BlogTheme from '@sugarat/theme'

// 全局组件
import redirectBtn from './src/components/redirectBtn.vue'
import Solve from './src/components/solve.vue'

const inBrowser = typeof window !== 'undefined'

export default {
  ...BlogTheme,
  enhanceApp: (ctx: EnhanceAppContext) => {
    const { app } = ctx
    BlogTheme?.enhanceApp?.(ctx)
    app.component('redirectBtn', redirectBtn)
    app.component('solve', Solve)

    if (inBrowser) {
      //  添加重定向逻辑，兼容旧版博客的分类和标签逻辑
      ctx.router.onBeforeRouteChange = (to) => {
        const url = new URL(to, window.location.origin)
        const pattern = /(categories|tag)\/(.*)\/$/
        if (pattern.test(url.pathname)) {
          const tagName = url.pathname.match(pattern)?.[2]
          if (tagName) {
            window.location.replace(
              `${window.location.origin}${ctx.router.route.path}?tag=${tagName}`
            )
          }
        }
      }

      // 添加博客运行时间计数器
      var targetDate = new Date('2023-12-29T00:00:00')

      function updateCountdown() {
        // 当前日期和时间
        var currentDate = new Date()

        // 计算剩余时间（以毫秒为单位）
        var timeDiff = currentDate.getTime() - targetDate.getTime()

        // 计算剩余的天、时，分、秒
        var days = Math.floor(timeDiff / (1000 * 60 * 60 * 24))
        var hours = Math.floor((timeDiff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
        var minutes = Math.floor((timeDiff % (1000 * 60 * 60)) / (1000 * 60))
        var seconds = Math.floor((timeDiff % (1000 * 60)) / 1000)

        // 更新显示剩余时间的容器
        var blogRunTimeElement = document.getElementById('blogRunTime')
        if (blogRunTimeElement) {
          blogRunTimeElement.innerHTML = days + ' d ' + hours + ' h ' + minutes + ' m ' + seconds + ' s '
        }

        // 获取当前年份
        var year = currentDate.getFullYear()
        var yearElement = document.getElementById('year')
        if (yearElement) {
          yearElement.innerHTML = String(year)
        }
      }

      // 初始调用一次更新函数
      updateCountdown()

      // 每隔一秒调用一次更新函数
      setInterval(updateCountdown, 1000)
    }
  }
}
