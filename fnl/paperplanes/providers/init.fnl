;; The user should be able to specify providers by a nice
;; "url like" name, so this just maps those names to modules.
{:dpaste.org (require :paperplanes.providers.dpasteorg)
 :ix.io (require :paperplanes.providers.ixio)
 :0x0.st (require :paperplanes.providers.0x0st)
 :sprunge.us (require :paperplanes.providers.sprungeus)
 :paste.rs (require :paperplanes.providers.pasters)
 :sr.ht (require :paperplanes.providers.srht)
 :ray.so (require :paperplanes.providers.rayso)}
