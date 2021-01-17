## Set up environment and load required packages
using NGWP, JLD, MAT, Plots, LightGraphs, MTSG
gr(dpi = 200)

## Build weighted sunflower graph
G, L, X = SunFlowerGraph(N = 400); N = nv(G)
𝛌, 𝚽 = eigen(Matrix(L)); sgn = (maximum(𝚽, dims = 1)[:] .> -minimum(𝚽, dims = 1)[:]) .* 2 .- 1; 𝚽 = 𝚽 * Diagonal(sgn);
Q = incidence_matrix(G; oriented = true)
W = 1.0 * adjacency_matrix(G)
edge_weight = [e.weight for e in edges(G)]

## Build Dual Graph by DAG metric
distDAG = eigDAG_Distance(𝚽,Q,N; edge_weight = edge_weight)
W_dual = sparse(dualGraph(distDAG)) #required: sparse dual weighted adjacence matrix

## Assemble wavelet packets
ht_elist_PC, ht_vlist_PC = HTree_EVlist(𝚽,W_dual)
wavelet_packet_PC = HTree_wavelet_packet(𝚽,ht_vlist_PC,ht_elist_PC)
ht_elist_VM = ht_elist_PC
wavelet_packet_VM = HTree_wavelet_packet_varimax(𝚽,ht_elist_VM)

## Fig. 6(b) barbara eye graph signal
f = matread(joinpath(@__DIR__, "..", "datasets", "sunflower_barbara_voronoi.mat"))["f_eye_voronoi"]
scatter_gplot(X; marker = f, ms = LinRange(4.0, 14.0, N), smallValFirst = false, c = :greys); signal_plt = plot!(xlim = [-1.2,1.2], ylim = [-1.2,1.2], frame = :none)
savefig(signal_plt, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_feye.png"))

## Fig. 6(c) barbara eye relative l2 approximation error by various methods
DVEC = signal_transform_coeff(f, ht_elist_PC, ht_elist_VM, wavelet_packet_PC, wavelet_packet_VM, 𝚽, W, X)
approx_error_plot2(DVEC); approx_error_plt = plot!(legend = :topright, xguidefontsize=16, yguidefontsize=16, legendfontsize=12)
savefig(approx_error_plt, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_feye_DAG_approx.png"))

## Fig. 7 barbara eye 9 most important VM-NGWP vectors (ignore the DC vector)
parent_VM = HTree_findParent(ht_elist_VM); Wav_VM = best_basis_selection(f, wavelet_packet_VM, parent_VM); dvec_VM = Wav_VM' * f
importance_idx = sortperm(abs.(dvec_VM), rev = true)
for i = 2:10
    scatter_gplot(X; marker = Wav_VM[:,importance_idx[i]], ms = LinRange(4.0, 14.0, N), smallValFirst = false, c = :greys); important_NGW_basis_vectors = plot!(xlim = [-1.2,1.2], ylim = [-1.2,1.2], frame = :none)
    savefig(important_NGW_basis_vectors, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_feye_DAG_VM_NGW_important_basis_vector$(i).png"))
end

## Fig. 8(b) barbara pants graph signal
f = matread(joinpath(@__DIR__, "..", "datasets", "sunflower_barbara_voronoi.mat"))["f_trouser_voronoi"]
scatter_gplot(X; marker = f, ms = LinRange(4.0, 14.0, N), smallValFirst = false, c = :greys); signal_plt = plot!(xlim = [-1.2,1.2], ylim = [-1.2,1.2], frame = :none)
savefig(signal_plt, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_ftrouser.png"))

## Fig. 8(c) barbara eye relative l2 approximation error by various methods
DVEC = signal_transform_coeff(f, ht_elist_PC, ht_elist_VM, wavelet_packet_PC, wavelet_packet_VM, 𝚽, W, X)
approx_error_plot2(DVEC); approx_error_plt = plot!(legend = :topright, xguidefontsize=16, yguidefontsize=16, legendfontsize=12)
savefig(approx_error_plt, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_ftrouser_DAG_approx.png"))

## Fig. 9 barbara eye 9 most important PC-NGWP vectors (ignore the DC vector)
parent_PC = HTree_findParent(ht_elist_PC); Wav_PC = best_basis_selection(f, wavelet_packet_PC, parent_PC); dvec_PC = Wav_PC' * f
importance_idx = sortperm(abs.(dvec_PC), rev = true)
for i = 2:10
    w = Wav_PC[:,importance_idx[i]]
    sgn = (maximum(w) > -minimum(w)) * 2 - 1
    scatter_gplot(X; marker = sgn .* w, ms = LinRange(4.0, 14.0, N), smallValFirst = false, c = :greys); important_NGW_basis_vectors = plot!(xlim = [-1.2,1.2], ylim = [-1.2,1.2], frame = :none)
    savefig(important_NGW_basis_vectors, joinpath(@__DIR__, "../paperfigs/SunFlower_barbara_ftrouser_DAG_PC_NGW_important_basis_vector$(i).png"))
end
