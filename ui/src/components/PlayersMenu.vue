<script>
import Nui from '../nui'
import PlayersModal from './PlayersModal.vue';

export default {
    components: {
        PlayersModal,
    },
    data() {
        return {
            players: [],
            filteredPlayers: this.players,
            showPlayer: false,
            playerData: {},
            filter: 'all',
            search: '',
        }
    },
    methods: {
        fetchPlayers() {
            Nui('refreshData')
        },
        onCloseModal() {
            this.showPlayer = false;
            setTimeout(() => {
                this.playerData = {}
            }, 500);
        },
        updateFilteredPlayers() {
            const searchLower = this.search.toLowerCase();

            this.filteredPlayers = this.players.filter((v) => {
                const matchesSearch =
                    v.name.toString().toLowerCase().includes(searchLower) ||
                    v.id.toString().includes(this.search) ||
                    v.ip.toString().includes(this.search);

                if (this.filter === 'clean') {
                    return !v.vpnInfo?.isProxy && matchesSearch;
                } else if (this.filter === 'vpndetected') {
                    return v.vpnInfo?.isProxy && matchesSearch;
                } else if (this.filter === 'all') {
                    return matchesSearch;
                }

                return false;
            });
        }
    },
    props: {
        show: Boolean,
    },
    watch: {
        show(val) {
            if (!val && this.showPlayer) {
                this.onCloseModal()
            }
        },
        filter() {
            this.updateFilteredPlayers();
        },
        search() {
            this.updateFilteredPlayers();
        }
    },
    mounted() {
        window.addEventListener('message', (event)=>{
            const data = event.data
            switch(data.type) {
                case 'players':
                    this.players = data.players
                    this.filteredPlayers = data.players
                break;
            }
        })
    },
}
</script>

<template>
    <div v-show="show">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-white">Connected Players</h2>
            <button class="flex flex-row space-x-2 justify-center items-center bg-accent/10 text-accent px-4 py-2 rounded-lg hover:bg-accent/20 transition-colors outline-none">
                <i class="fa-solid fa-arrows-rotate"></i>
                <p>Refresh</p>
            </button>
        </div>

        <div class="flex justify-between mb-2">
            <div class="flex items-center bg-dashboard-darker p-2 px-3 space-x-2 rounded-lg w-64">
                <i class="fa-solid fa-filter text-white bg-accent/20 p-2 rounded-lg"></i>
                <select name="filter" class="bg-button-hover text-white placeholder-white text-sm rounded-lg w-full p-1 outline-none" v-model="filter">
                    <option value="all">All</option>
                    <option value="clean">Clean</option>
                    <option value="vpndetected">VPN Detected</option>
                </select>
            </div>
            <div class="flex bg-dashboard-darker p-2 px-3 space-x-2 rounded-lg w-64">
                <i class="fa-solid fa-magnifying-glass text-white bg-accent/20 p-2 rounded-lg"></i>
                <input class="bg-transparent w-auto outline-none text-white" type="text" placeholder="Search..." v-model="search"></input>
            </div>
        </div>
        <div class="bg-dashboard-darker rounded-xl border border-gray-700/50">
            <div class="flex flex-col min-h-10 max-h-[50rem] overflow-auto rounded-xl">
                <table class="">
                    <thead class="sticky top-0 bg-gray-800">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Name</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">IP</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Status</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-800/50">
                        <template v-for="player in filteredPlayers">
                            <tr class="hover:bg-gray-800/20">
                                <td class="text-white px-6 py-4">{{ player.id || '0' }}</td>
                                <td class="text-white px-6 py-4">{{ player.name || 'NULL' }}</td>
                                <td class="text-white px-6 py-4 blur-sm hover:blur-none">{{ player.ip || '0.0.0.0' }}</td>
                                <td class="text-white px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full" :class="(player.vpnInfo?.isProxy) ? 'bg-red-500/10 text-red-500' : 'bg-green-500/10 text-green-500'">
                                        {{ (player.vpnInfo?.isProxy) ? 'VPN Detected' : 'Clean' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <button class="text-accent hover:text-accent/80 outline-none" @click="playerData = player; showPlayer = true">View Details</button>
                                </td>
                            </tr>
                        </template>
                    </tbody>
                </table>
            </div>
        </div>

        <Transition>
            <PlayersModal 
                :show="showPlayer"
                :player="playerData"
                @closeModal="onCloseModal()"
            ></PlayersModal>
        </Transition>
    </div>
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

/* width */
::-webkit-scrollbar {
  width: 0px;
}

/* Track */
::-webkit-scrollbar-track {
  background: #f1f1f100;
}

/* Handle */
::-webkit-scrollbar-thumb {
  background: #263b6b00;
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
  background: #172340;
}
</style>