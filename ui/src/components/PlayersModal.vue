<script>
export default {
    data() {
        return {

        }
    },
    methods: {

    },
    props: {
        show: Boolean,
        player: Object,
    },
}
</script>

<template>
    <div v-show="show" class="absolute inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center">
        <div class="bg-dashboard-darker rounded-xl border border-gray-700/50 p-6 max-w-2xl w-full mx-4">
            <div class="flex justify-between items-center mb-6">
                <h3 class="text-xl font-bold text-white">Player Details</h3>
                <button class="text-red-500 hover:text-red-500/50" @click="$emit('closeModal')">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="flex flex-col space-y-4">
                <div class="flex flex-row space-x-4">
                    <div class="grow bg-gray-800/30 p-4 rounded-lg">
                        <h4 class="text-gray-400 text-sm mb-2">Basic Info</h4>
                        <p class="text-white">Name: {{ player.name || '' }}</p>
                        <p class="text-white">ID: {{ player.id || '' }}</p>
                        <p class="text-white">IP: <a class="blur-sm hover:blur-none">{{ player.ip || '0.0.0.0' }}</a></p>
                        <p class="text-white">Join Time: {{ player.joinTime ? (new Date(player.joinTime * 1000).toLocaleString()) : 'Unknown' }}</p>
                    </div>
                    <div class="grow bg-gray-800/30 p-4 rounded-lg">
                        <h4 class="text-gray-400 text-sm mb-2">Connection Info</h4>
                        <p class="text-white">VPN/Proxy: {{ player.vpnInfo?.isProxy ? 'Yes' : 'No' }}</p>
                        <p class="text-white">Country: {{ player.vpnInfo?.country || 'Unknown' }}</p>
                        <p class="text-white">Provider: {{ player.vpnInfo?.provider || 'Unknown' }}</p>
                        <p class="text-white">Risk Level: {{ player.vpnInfo?.risk || 'Unknown' }}</p>
                    </div>
                </div>
                <div class="bg-gray-800/30 p-4 rounded-lg col-span-2">
                    <h4 class="text-gray-400 text-sm mb-2">Identifiers</h4>
                    <template v-for="(identifier, type) in player.identifiers">
                        <div class="flex flex-row">
                            <p class="text-white" :class="type == 'ip' && 'blur-sm hover:blur-none'">{{ identifier }}</p>
                        </div>
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>