<script>
import Nui from '../nui'

export default {
    data() {
        return {
            settings: {
                CACHE_DURATION: 24,
                ENABLE_DEBUG: false,
                ENABLE_ANTIVPN: true,
            },
            success: false,
        }
    },
    methods: {
        saveSettings() {
            Nui('saveSettings', this.settings)
            this.success = true;
            setTimeout(() => {
                this.success = false;
            }, 2000);
        },
        clearCache() {
            Nui('clearCache')
            this.success = true;
            setTimeout(() => {
                this.success = false;
            }, 2000);
        },
    },
    props: {
        show: Boolean,
    },
    mounted() {
        window.addEventListener('message', (event)=>{
            const data = event.data
            switch(data.type) {
                case 'settings':
                    this.settings = data.settings
                break;
            }
        })
    },
}
</script>

<template>
    <div v-show="show" class="space-y-6">
        <h2 class="text-2xl font-bold text-white">Settings</h2>
        
        <div class="flex flex-row space-x-6">
            <div class="grow bg-dashboard-darker rounded-xl border border-gray-700/50 p-6">
                <h3 class="text-xl font-semibold mb-4 text-white">Cache Settings</h3>
                <div class="space-y-4">
                    <div>
                        <label class="block text-gray-400 text-sm mb-2">Cache Duration (hours)</label>
                        <input type="number" id="cacheDuration" class="w-full bg-gray-800/30 border border-gray-700/50 rounded-lg px-4 py-2 text-white" :value="settings.CACHE_DURATION">
                    </div>
                    <button class="bg-red-500/10 text-red-500 px-4 py-2 rounded-lg hover:bg-red-500/20 transition-colors outline-none" @click="clearCache()">Clear Cache</button>
                </div>
            </div>

            <div class="grow bg-dashboard-darker rounded-xl border border-gray-700/50 p-6">
                <h3 class="text-xl font-semibold mb-4 text-white">Debug Settings</h3>
                <div class="space-y-4">
                    <div class="flex items-center space-x-2">
                        <input type="checkbox" class="w-4 h-4 text-blue-600 bg-gray-100 rounded-lg" v-model="settings.ENABLE_DEBUG">
                        <label class="text-gray-400">Enable Debug Mode</label>
                    </div>
                    <div class="flex items-center space-x-2">
                        <input type="checkbox" class="w-4 h-4 text-blue-600 bg-gray-100 rounded-lg" v-model="settings.ENABLE_ANTIVPN">
                        <label class="text-gray-400">Enable Anti VPN</label>
                    </div>
                </div>
            </div>
        </div>

        <button class="bg-green-400/30 text-green-400 px-4 py-2 rounded-lg hover:bg-green-500/20 transition-colors outline-none" @click="saveSettings()">Save Settings</button>

        <div v-show="success" class="absolute inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center">
            <div class="motion-preset-bounce -motion-translate-y-in-150">
                <div class="motion-delay-150 motion-preset-oscillate">
                    <i class="fa-solid fa-circle-check text-green-400 text-8xl"></i>
                </div>
            </div>
        </div>
    </div>
</template>