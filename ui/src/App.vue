<script>
import Nui from './nui'
import DashBoard from './components/DashBoard.vue';
import PlayersMenu from './components/PlayersMenu.vue';
import SettingsMenu from './components/SettingsMenu.vue';


export default {
  components: {
    DashBoard,
    PlayersMenu,
    SettingsMenu,
  },
  data() {
    return {
      menu: 'dashboard',
      show: false,
      status: {},
    }
  },
  methods: {
    changeCategory(category) {
      if (this.menu == '') return;
      this.menu = '';
      setTimeout(() => {
        this.menu = category;
      }, 500);
    },
    closeMenu() {
      this.show = false;
      Nui('closeUI')
    },
  },
  mounted() {
    window.addEventListener('message', (event)=>{
      const data = event.data
      switch(data.type) {
        case 'menu':
          this.show = data.show
          if (data.show) {
            this.status = data.status
          }
        break;
      }
    })

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.show) {
        this.closeMenu();
      }
    })
  },
}
</script>

<template>
  <Transition>
    <div class="flex items-center justify-center w-screen h-screen" v-show="show">
      <div class="flex w-3/5 h-4/5 bg-dashboard-dark rounded-xl shadow-2xl border border-gray-800/50">
        <div class="relative flex flex-col w-1/5 p-6 rounded-l-xl border-r border-gray-800/50 bg-dashboard-darker">
          <div class="flex items-center space-x-3 mb-8">
              <div class="flex w-8 h-8 rounded-lg bg-accent/20 items-center justify-center">
                  <i class="fa-solid fa-shield-cat text-accent text-lg"></i>
              </div>
              <h2 class="text-xl font-bold text-white">VelocityLayer</h2>
          </div>

          <div class="flex flex-col space-y-2 text-white">
            <button class="flex items-center space-x-2 p-2 rounded-md nav-link active w-full hover:bg-button-hover outline-none" :class="menu == 'dashboard' ? 'bg-button-selected' : 'bg-dashboard-dark'" @click="changeCategory('dashboard')">
              <i class="fa-solid fa-square-poll-vertical p-1"></i>
              <span>Dashboard</span>
            </button>
            
            <button class="flex items-center space-x-2 p-2 rounded-md nav-link w-full hover:bg-button-hover outline-none" :class="menu == 'players' ? 'bg-button-selected' : 'bg-dashboard-dark'" @click="changeCategory('players')">
              <i class="fa-solid fa-user-shield p-1"></i>
              <span>Players</span>
            </button>

            <button class="flex items-center space-x-2 p-2 rounded-md nav-link w-full hover:bg-button-hover outline-none" :class="menu == 'settings' ? 'bg-button-selected' : 'bg-dashboard-dark'" @click="changeCategory('settings')">
              <i class="fa-solid fa-gear p-1"></i>
              <span>Settings</span>
            </button>
          </div>

          <div class="mt-8 pt-8 border-t border-gray-800/50">
            <div class="bg-gray-800/20 rounded-xl p-4">
              <div class="flex items-center justify-between mb-3">
                <span class="text-sm text-gray-400">{{ !status.errors ? 'Operational' : 'Error Detected' }}</span>
                <span class="flex h-3 w-3">
                    <span class="animate-ping absolute inline-flex h-3 w-3 rounded-full" :class="status.errors ? 'bg-red-400 opacity-75' : 'bg-green-400 opacity-75'"></span>
                    <span class="relative inline-flex rounded-full h-3 w-3" :class="status.errors ? 'bg-red-500' : 'bg-green-500'"></span>
                </span>
              </div>
              <div class="text-sm text-gray-400">
                <p>Cached IPs: <span>{{ status.cacheSize }}</span></p>
                <p>Last Cleanup: <span>{{ status.clearTime ? (new Date(status.clearTime * 1000).toLocaleString()) : 'Unknown' }}</span></p>
              </div>
            </div>
          </div>

          <div class="absolute flex flex-row justify-center items-center space-x-2 bottom-8 left-6 px-2 py-1 rounded-lg border border-gray-700/50">
            <i class="fa-solid fa-circle text-accent text-xs"></i>
            <p class="text-white font-bold">1.0.0</p>
          </div>
        </div>

        <div class="relative flex flex-col p-8 w-4/5 h-full">
          <Transition>
            <DashBoard :show="menu == 'dashboard'"></DashBoard>
          </Transition>

          <Transition>
            <PlayersMenu :show="menu == 'players'"></PlayersMenu>
          </Transition>
          <Transition>
            <SettingsMenu :show="menu == 'settings'"></SettingsMenu>
          </Transition>
          
          <button class="absolute bottom-8 right-8 bg-red-500/10 text-red-500 px-4 py-2 rounded-lg hover:bg-red-500/20 transition-colors outline-none" @click="closeMenu()">Close Dashboard</button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.v-enter-active,
.v-leave-active {
  transition: opacity 0.5s ease;
}

.v-enter-from,
.v-leave-to {
  opacity: 0;
}
</style>
