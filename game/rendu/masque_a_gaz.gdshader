// CE QU'ON VOIT QUAND ON PORTE LE MASQUE A GAZ.
//
// « L'effet masque est sympa mais il faudra l'accentuer BEAUCOUP plus. Faire en
// sorte que ce soit beaucoup plus difficile d'y voir quoi que ce soit. Rajouter
// un effet "low shutter" comme si le personnage etait sonne. » — retour du
// 23/08/2026.
//
// CE QUI A CHANGE, ET POURQUOI LE PREMIER REGLAGE ETAIT DEFENDABLE. Le script
// disait « vision LEGEREMENT filtree », et le garde-fou d'alors etait qu'il
// faut voir les deux corps a l'arriere. Le retour supprime les deux : la vision
// doit etre « trouble et ILLISIBLE, on ne sait pas ou on est, ni ou on va
// vraiment », et regarder les corps sort du suivi de mission. Le joueur ne
// cherche plus rien a l'ecran — il suit une VOIX.
//
// ON NE LIT TOUJOURS PAS L'ECRAN, et cette fois c'est une mesure et non un
// principe : hint_screen_texture a ete releve a +4,3 ms par image sur ce projet
// (voir liquide.gdshader). Une vraie remanence d'obturateur lent en aurait
// besoin. Ce qui suit obtient le meme RESSENTI en trois gestes qui ne coutent
// rien : un champ tres ferme, une respiration ample, et un battement qui
// assombrit l'image par vagues irregulieres.
//
// Le « low shutter » n'est donc pas simule optiquement — il est simule dans ce
// qu'il fait au spectateur : on perd l'image par intermittence, et on ne sait
// jamais quand elle revient.
shader_type canvas_item;
render_mode blend_mix, unshaded;

// La teinte du verre. Legerement verte et desaturee : c'est du polycarbonate
// teinte, pas une lunette de vision nocturne.
//
// PLUS SOMBRE QU'AVANT, et pour une raison qui a change : la scene se joue
// desormais de JOUR — « la mission doit imperativement se derouler la
// journee ». Une teinte reglee pour une nuit noire devient transparente sous un
// soleil de fin d'apres-midi.
uniform vec4 teinte : source_color = vec4(0.22, 0.29, 0.24, 1.0);

// Ce qu'on voit dans le coin de l'oeil, c'est-a-dire plus rien du tout.
uniform vec4 bordure : source_color = vec4(0.02, 0.03, 0.03, 0.99);

// Opacite de la teinte AU CENTRE.
//
// 0.40 avant, sur l'idee qu'il fallait pouvoir jouer. C'est justement ce que le
// retour refuse : « beaucoup plus difficile d'y voir quoi que ce soit ». A 0.72
// il reste une lucarne au centre ou l'on devine des masses et des mouvements,
// et rien d'autre — assez pour marcher sans mur invisible, pas assez pour
// reconnaitre un camping-car.
uniform float voile : hint_range(0.0, 0.95) = 0.72;

// OU COMMENCE ET OU FINIT LA FERMETURE DU CHAMP, en rayon normalise.
//
// d vaut 0 au centre, 1.0 au milieu des bords haut et bas, 1.50 dans les coins.
// Le reglage precedent (0.50 / 1.34) gardait tout le cadre lisible et ne
// fermait vraiment que les angles.
//
// Ici la lucarne se referme AVANT le bord de l'ecran : le noir mange les deux
// tiers de l'image. C'est ce qui fait qu'on ne sait pas ou l'on est — on ne
// voit pas assez large pour reconnaitre un lieu.
uniform float ouverture : hint_range(0.1, 1.6) = 0.26;
uniform float fermeture : hint_range(0.1, 2.2) = 0.92;

// LA RESPIRATION. Ample, maintenant : le champ se resserre et s'ouvre de
// treize pour cent, lentement. Un masque qu'on porte quand on est sonne ne se
// tient pas immobile devant les yeux.
uniform float souffle : hint_range(0.0, 0.4) = 0.13;
uniform float cadence = 0.7;

// LE BATTEMENT — la part « low shutter ».
//
// L'image s'assombrit par vagues, et les vagues ne tombent pas en rythme : deux
// sinus de periodes premieres entre elles ne se resynchronisent jamais a
// l'echelle de la scene. C'est ce qui separe un clignotement d'un malaise —
// un rythme regulier s'anticipe, et on cesse de le subir au bout de dix
// secondes.
uniform float battement : hint_range(0.0, 0.6) = 0.22;

// LA TETE QUI TANGUE. Le centre du champ derive lentement, de quelques pour
// cent : on ne regarde pas droit devant soi quand on vient de se reveiller au
// fond d'un fosse.
uniform float tangage : hint_range(0.0, 0.2) = 0.035;

void fragment() {
	// L'ecran est plus large que haut ; sans correction la fermeture serait un
	// cercle et laisserait deux coins vides en haut et en bas.
	vec2 centre = vec2(
			sin(TIME * 0.37) * tangage,
			cos(TIME * 0.23) * tangage * 0.7);
	vec2 c = (UV - vec2(0.5) - centre) * vec2(1.12, 1.0);
	float d = length(c) * 2.0;

	// Inspiration lente, expiration lente.
	float r = ouverture * (1.0 - souffle * (sin(TIME * cadence) * 0.5 + 0.5));

	// Les deux vagues du battement. La seconde est plus lente et moins ample :
	// elle deplace les creux de la premiere au lieu de s'y ajouter.
	float vague = sin(TIME * 1.7) * 0.5 + 0.5;
	float lente = sin(TIME * 0.61) * 0.5 + 0.5;
	float noir = battement * (vague * 0.65 + lente * 0.35);

	float bord = smoothstep(r, fermeture, d);
	float a = mix(voile, bordure.a, bord);
	// Le battement s'ajoute AU CENTRE surtout : les bords sont deja noirs, et
	// les faire clignoter ne se verrait pas.
	a = clamp(a + noir * (1.0 - bord), 0.0, 1.0);
	COLOR = vec4(mix(teinte.rgb, bordure.rgb, bord), a);
}
