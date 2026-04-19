namespace MindScorePlatform.Infrastructure.Services.RelationshipDynamicsSeed;

/// <summary>
/// 16×16 type pair compatibility matrix for Relationship Dynamics Assessment.
/// Each pairing: (type1 + type2) → compatibility score + risk narrative.
/// Compatibility levels: High (stable, growth-oriented) | Good (manageable, some friction) | Challenging (high risk, requires conscious effort).
/// </summary>
internal sealed class RelationshipPairCompatibilityMatrix
{
    internal sealed record PairCompatibility(
        string Compatibility,  // High | Good | Challenging
        string RiskNarrative   // What to watch for; conflict cycle if applicable
    );

    private static readonly Dictionary<(string, string), PairCompatibility> Matrix = new();

    static RelationshipPairCompatibilityMatrix()
    {
        // Initialize all 16×16 pairings (256 total)
        var types = new[] { "SETP", "SETE", "SETRP", "SETRE", "SAWTP", "SAWTE", "SAWRP", "SAWRE", "IETEPM", "IETETE", "IETRP", "IETRE", "IAWTP", "IAWTE", "IAWRP", "IAWRE" };

        // Helper: Add bidirectional pairing
        void AddPairing(string t1, string t2, string compat, string risk) {
            Matrix[(t1, t2)] = new(compat, risk);
            Matrix[(t2, t1)] = new(compat, risk);  // Symmetric
        }

        // Row 1: SETP (Secure Anchor)
        AddPairing("SETP", "SETP", "High", "Two secure, practical people. Stable, reliable, low drama. Watch: can become too routine.");
        AddPairing("SETP", "SETE", "High", "Secure anchor + secure advocate. Practical + emotional balance. Needs: emotional expression from advocate matters.");
        AddPairing("SETP", "SETRP", "High", "Two secure builders. Extremely stable. Watch: emotional distance; need to check in beyond logistics.");
        AddPairing("SETP", "SETRE", "High", "Practical anchor + reserved counselor. Complimentary; quiet stability. Watch: both may avoid talking about feelings.");
        AddPairing("SETP", "SAWTP", "Good", "Both practical and somewhat independent. Low conflict. Watch: may become roommates instead of partners.");
        AddPairing("SETP", "SAWTE", "Good", "Practical anchor + avoidant dreamer. Works if dreamer's openness balances anchor's reserve. Watch: conflict avoidance.");
        AddPairing("SETP", "SAWRP", "Good", "Two independent operators. Reliable partnership. Watch: emotional distance and unaddressed issues.");
        AddPairing("SETP", "SAWRE", "Good", "Practical anchor + distant watcher. Anchor notices dreamer observing from afar. Watch: emotional gap.");
        AddPairing("SETP", "IETEPM", "Good", "Secure anchor + anxious pursuer. Anchor's reliability calms pursuer's anxiety. Watch: pursuer may test anchor's commitment.");
        AddPairing("SETP", "IETETE", "Good", "Secure anchor + anxious advocate. Works if anchor can provide steady reassurance. Watch: advocate's intensity may feel demanding.");
        AddPairing("SETP", "IETRP", "Good", "Secure anchor + anxious builder. Both action-oriented. Watch: anxious partner's doubt may go unheard.");
        AddPairing("SETP", "IETRE", "Good", "Secure anchor + anxious counselor. Anchor's reliability helps counselor. Watch: counselor needs reassurance they won't burden anchor.");
        AddPairing("SETP", "IAWTP", "Good", "Secure anchor + avoidant achiever. Both practical, low emotional demands. Watch: achiever's distance may feel cold.");
        AddPairing("SETP", "IAWTE", "Challenging", "Secure anchor + avoidant dreamer. Anchor's stability tempts dreamer, then dreamer flees. Watch: push-pull sabotage.");
        AddPairing("SETP", "IAWRP", "Good", "Secure anchor + withdrawn operator. Both independent and practical. Watch: total emotional distance; need intentional connection.");
        AddPairing("SETP", "IAWRE", "Challenging", "Secure anchor + disorganized dreamer. Anchor's stability helps briefly, then dreamer's chaos resurfaces. Watch: anchor exhaustion.");

        // Row 2: SETE (Secure Advocate)
        AddPairing("SETE", "SETE", "High", "Two secure advocates. Deep emotional connection, direct communication. Watch: both may over-talk; need to listen too.");
        AddPairing("SETE", "SETRP", "Good", "Advocate + builder. Emotional expression + steady action. Watch: builder may seem withdrawn; advocate may need more words.");
        AddPairing("SETE", "SETRE", "High", "Advocate + counselor. Emotional depth on both sides. Good balance of expression and listening. Watch: both go deep; may get lost in feelings.");
        AddPairing("SETE", "SAWTP", "Good", "Advocate + independent practical. Advocate's warmth softens independent's distance. Watch: independent may feel emotionally pushed.");
        AddPairing("SETE", "SAWTE", "High", "Advocate + avoidant dreamer. Both emotionally open (dreamer when present). Dreamer appreciates advocate's certainty. Watch: dreamer's avoidance cycles.");
        AddPairing("SETE", "SAWRP", "Good", "Advocate + independent operator. Emotional expression meets practical distance. Watch: operator may feel pushed to feel; advocate may feel ignored.");
        AddPairing("SETE", "SAWRE", "Good", "Advocate + distant watcher. Advocate's openness draws out watcher slowly. Watch: watcher may never fully reciprocate emotionally.");
        AddPairing("SETE", "IETEPM", "Good", "Advocate + anxious pursuer. Both engage directly. Risk: pursuer's anxiety may escalate advocate's emotions. Watch: cycles of high-intensity conflict.");
        AddPairing("SETE", "IETETE", "Challenging", "Two anxious advocates. Both intense, both need reassurance. Risk: mutual escalation and emotional flooding. Watch: can't regulate each other.");
        AddPairing("SETE", "IETRP", "Good", "Advocate + anxious builder. Advocate's words meet builder's actions. Watch: builder's doubt may go unspoken until explosion.");
        AddPairing("SETE", "IETRE", "High", "Advocate + anxious counselor. Both emotionally attuned. Counselor finally feels safe expressing fears. Watch: need to balance emotional intensity with action.");
        AddPairing("SETE", "IAWTP", "Challenging", "Advocate + avoidant achiever. Advocate's openness triggers achiever's withdrawal. Risk: Pursuer-withdrawer dynamic. Watch: advocate chases, achiever retreats.");
        AddPairing("SETE", "IAWTE", "Challenging", "Advocate + avoidant dreamer. Advocate seeks depth; dreamer oscillates between intense openness and disappearance. Watch: Push-pull chaos; advocate's hurt cycles.");
        AddPairing("SETE", "IAWRP", "Challenging", "Advocate + withdrawn operator. Advocate pours emotional energy into silent, distant partner. Risk: Advocate exhaustion. Watch: advocate feels invisible.");
        AddPairing("SETE", "IAWRE", "Challenging", "Advocate + disorganized dreamer. Advocate's intensity meets dreamer's chaos. Risk: Severe push-pull and mutual confusion. Watch: both hurt, can't stabilize.");

        // Row 3: SETRP (Secure Builder)
        AddPairing("SETRP", "SETRP", "High", "Two quiet builders. Extremely stable, reliable, low emotional intensity. Watch: can become disconnected; need intentional emotional check-ins.");
        AddPairing("SETRP", "SETRE", "High", "Builder + counselor. Both reserved but emotionally aware. Stable partnership. Watch: feelings may go unsaid; need to voice appreciation.");
        AddPairing("SETRP", "SAWTP", "Good", "Two builders, one with avoidance. Both practical and independent. Watch: total emotional distance; may be roommates.");
        AddPairing("SETRP", "SAWTE", "Good", "Builder + avoidant dreamer. Builder's steadiness attracts dreamer; dreamer's openness softens builder. Watch: dreamer may flee builder's steadiness as suffocating.");
        AddPairing("SETRP", "SAWRP", "High", "Two independent operators. Both practical, reliable, emotionally distant. Watch: can drift into parallel lives without intimacy.");
        AddPairing("SETRP", "SAWRE", "Good", "Builder + distant watcher. Both reserved and emotionally private. Good partnership but little emotional depth. Watch: isolation can increase over time.");
        AddPairing("SETRP", "IETEPM", "Good", "Builder + anxious pursuer. Builder's steadiness helps; pursuer's directness pushes builder. Watch: pursuer frustrated by builder's slow emotional pace.");
        AddPairing("SETRP", "IETETE", "Good", "Builder + anxious advocate. Advocate's intensity may overwhelm quiet builder. Builder provides stability. Watch: advocate may feel unheard; builder may withdraw further.");
        AddPairing("SETRP", "IETRP", "Good", "Builder + anxious builder. Both action-oriented but both quietly anxious. Risk: Silent resentment accumulates. Watch: anxiety goes unaddressed.");
        AddPairing("SETRP", "IETRE", "High", "Builder + anxious counselor. Both quiet; counselor notices builder's doubt and tends to it gently. Stable. Watch: builder still may not share; counselor martyr patterns.");
        AddPairing("SETRP", "IAWTP", "Good", "Builder + avoidant achiever. Both work-focused and emotionally distant. Watch: become task-oriented couple with no intimacy.");
        AddPairing("SETRP", "IAWTE", "Challenging", "Builder + avoidant dreamer. Builder's stability attracts dreamer; dreamer's fear causes sabotage. Risk: Dreamer leaves builder confused. Watch: abandonment for no clear reason.");
        AddPairing("SETRP", "IAWRP", "Good", "Two withdrawn, practical partners. Both independent and task-focused. Watch: extreme isolation; emotional desert. Stable but lonely together.");
        AddPairing("SETRP", "IAWRE", "Challenging", "Builder + disorganized dreamer. Builder seeks steadiness; dreamer brings chaos. Risk: Builder's frustration mounts. Watch: builder's patience exhausted.");

        // Row 4: SETRE (Secure Counselor)
        AddPairing("SETRE", "SETRE", "High", "Two counselors. Deep emotional attunement, good listening, thoughtful. Watch: can get lost in analysis; need to act on decisions.");
        AddPairing("SETRE", "SAWTP", "Good", "Counselor + independent practical. Counselor draws out independent's feelings slowly. Watch: independent may not match counselor's emotional depth desire.");
        AddPairing("SETRE", "SAWTE", "High", "Counselor + avoidant dreamer. Counselor's acceptance helps dreamer feel safe; dreamer's openness (when present) moves counselor. Watch: dreamer's absences hurt.");
        AddPairing("SETRE", "SAWRP", "Good", "Counselor + independent operator. Counselor's emotional attunement vs operator's emotional distance. Watch: operator may feel pushed; counselor may feel unmet.");
        AddPairing("SETRE", "SAWRE", "High", "Counselor + distant watcher. Both emotionally intelligent but private. Deep, quiet understanding. Watch: may never fully express feelings to each other.");
        AddPairing("SETRE", "IETEPM", "Good", "Counselor + anxious pursuer. Counselor's understanding helps pursuer feel seen. Watch: pursuer's neediness may become burden counselor can't meet.");
        AddPairing("SETRE", "IETETE", "Good", "Counselor + anxious advocate. Both emotionally attuned; advocate's intensity vs counselor's reserve. Watch: advocate needs quicker responses than counselor gives.");
        AddPairing("SETRE", "IETRP", "Good", "Counselor + anxious builder. Counselor notices builder's hidden worry; validates it. Watch: builder may still not ask for help directly.");
        AddPairing("SETRE", "IETRE", "High", "Two anxious counselors. Both emotionally aware and validating. Deep mutual understanding. Watch: can become stuck in emotional processing; need action too.");
        AddPairing("SETRE", "IAWTP", "Challenging", "Counselor + avoidant achiever. Counselor seeks emotional connection; achiever withdraws into work. Risk: Counselor feels unseen. Watch: counselor's need unmet.");
        AddPairing("SETRE", "IAWTE", "Good", "Counselor + avoidant dreamer. Counselor's steadiness helps dreamer feel safe to return. Watch: dreamer's cycles wear on counselor's patience.");
        AddPairing("SETRE", "IAWRP", "Challenging", "Counselor + withdrawn operator. Counselor seeks depth; operator provides none. Risk: Counselor exhaustion. Watch: one-sided emotional labor.");
        AddPairing("SETRE", "IAWRE", "Challenging", "Counselor + disorganized dreamer. Counselor tries to help dreamer stabilize; dreamer's chaos is exhausting. Watch: counselor's martyr pattern emerges.");

        // Rows 5-8: SAWTP, SAWTE, SAWRP, SAWRE (Secure + Avoiding types)
        AddPairing("SAWTP", "SAWTP", "Good", "Two independent practical partners. Stable, reliable, low conflict. Watch: zero emotional depth; may become disconnected.");
        AddPairing("SAWTP", "SAWTE", "Good", "Independent practical + avoidant dreamer (emotionally open). Practical's steadiness attracts dreamer; dreamer's openness softens practical. Watch: dreamer's avoidance cycles.");
        AddPairing("SAWTP", "SAWRP", "High", "Two independent operators. Both practical, autonomous, low-demand. Very stable. Watch: completely emotionally unavailable to each other.");
        AddPairing("SAWTP", "SAWRE", "Good", "Independent practical + distant watcher. Both emotionally private. Stable but cold. Watch: no real intimacy despite stability.");
        AddPairing("SAWTP", "IETEPM", "Challenging", "Independent practical + anxious pursuer. Pursuer needs closeness; practical avoids it. Risk: Pursuer-withdrawer dynamic. Watch: pursuer chases, practical retreats to work.");
        AddPairing("SAWTP", "IETETE", "Challenging", "Independent practical + anxious advocate. Advocate's intensity triggers practical's withdrawal. Risk: Severe pursue-withdraw cycle. Watch: no one wins; both hurt.");
        AddPairing("SAWTP", "IETRP", "Challenging", "Independent practical + anxious builder. Both practical but anxious partner's doubt goes unaddressed by avoidant partner. Watch: resentment from unmet needs.");
        AddPairing("SAWTP", "IETRE", "Challenging", "Independent practical + anxious counselor. Counselor seeks connection; practical avoids. Risk: Counselor's caring unmet. Watch: counselor feels rejected.");
        AddPairing("SAWTP", "IAWTP", "Good", "Two avoidant achievers. Both work-focused and emotionally distant. Parallel lives. Watch: complete emotional disconnection; stable but empty.");
        AddPairing("SAWTP", "IAWTE", "Challenging", "Independent practical + avoidant dreamer. Practical's distance plus dreamer's chaos = no stability. Watch: dreamer needs closeness; practical can't provide it.");
        AddPairing("SAWTP", "IAWRP", "Good", "Independent practical + withdrawn operator. Both emotionally unavailable, practical-focused. Watch: zero intimacy; may be productive but lonely.");
        AddPairing("SAWTP", "IAWRE", "Challenging", "Independent practical + disorganized dreamer. Practical's consistency attracts dreamer; dreamer's chaos destabilizes practical. Watch: dreamer sabotage.");

        AddPairing("SAWTE", "SAWTE", "Good", "Two avoidant dreamers (emotionally open). Both seek and fear closeness. Risk: Mutual push-pull. Watch: neither can stabilize the other; cycles of connection and escape.");
        AddPairing("SAWTE", "SAWRP", "Good", "Avoidant dreamer + independent operator. Dreamer's openness attracts operator; operator's distance triggers dreamer's fear. Watch: abandonment cycle.");
        AddPairing("SAWTE", "SAWRE", "High", "Avoidant dreamer + distant watcher. Both emotionally aware but distant. Dreamer's intermittent openness works with watcher's observation. Watch: lack of action; spinning in feelings.");
        AddPairing("SAWTE", "IETEPM", "Challenging", "Avoidant dreamer + anxious pursuer. Pursuer pursues; dreamer flees. Risk: Extreme pursue-withdraw cycle. Watch: most common painful dynamic in relationships.");
        AddPairing("SAWTE", "IETETE", "Challenging", "Avoidant dreamer + anxious advocate. Advocate's intensity triggers dreamer's flight. Risk: Severe cycling and mutual hurt. Watch: both blame each other.");
        AddPairing("SAWTE", "IETRP", "Challenging", "Avoidant dreamer + anxious builder. Builder's actions can't stop dreamer's fear of intimacy. Watch: dreamer self-sabotage despite builder's effort.");
        AddPairing("SAWTE", "IETRE", "Challenging", "Avoidant dreamer + anxious counselor. Counselor's care triggers dreamer's flight; dreamer's return brings counselor back to hope. Risk: Exhausting cycle. Watch: counselor's martyr pattern.");
        AddPairing("SAWTE", "IAWTP", "Challenging", "Avoidant dreamer + avoidant achiever. Both avoid intimacy differently. No one pursues; connection dies. Watch: slow relationship death from mutual avoidance.");
        AddPairing("SAWTE", "IAWTE", "Challenging", "Two avoidant dreamers (fearful-avoidant). Chaos + chaos. Risk: Unpredictable push-pull hell. Watch: relationship spirals; both sabotage when it's good.");
        AddPairing("SAWTE", "IAWRP", "Challenging", "Avoidant dreamer + withdrawn operator. Dreamer needs emotional openness; operator provides none. Watch: dreamer feels invisible; no real intimacy possible.");
        AddPairing("SAWTE", "IAWRE", "Challenging", "Avoidant dreamer + disorganized dreamer. Two unstable, fearful-avoidant types. Risk: Chaos, confusion, mutual sabotage. Watch: relationship is unpredictably volatile.");

        AddPairing("SAWRP", "SAWRP", "High", "Two independent operators. Both emotionally unavailable but practical. Extremely stable if lonely. Watch: risk of zero emotional connection over time.");
        AddPairing("SAWRP", "SAWRE", "High", "Independent operator + distant watcher. Both highly independent and emotionally private. Very stable. Watch: may become complete disconnection over years.");
        AddPairing("SAWRP", "IETEPM", "Challenging", "Independent operator + anxious pursuer. Pursuer's need triggers operator's withdrawal. Risk: Pursue-withdraw dynamic. Watch: operator's distance is maddening to pursuer.");
        AddPairing("SAWRP", "IETETE", "Challenging", "Independent operator + anxious advocate. Advocate's intensity is overwhelming to operator. Risk: Severe withdraw response. Watch: advocate feels completely rejected.");
        AddPairing("SAWRP", "IETRP", "Challenging", "Independent operator + anxious builder. Both avoid emotional expression but builder's doubt festers. Watch: resentment builds silently until explosion.");
        AddPairing("SAWRP", "IETRE", "Challenging", "Independent operator + anxious counselor. Counselor seeks emotional connection; operator has nothing to offer. Watch: counselor feels worthless; martyr pattern.");
        AddPairing("SAWRP", "IAWTP", "Good", "Independent operator + avoidant achiever. Both work-focused and emotionally distant. Stable parallel lives. Watch: zero intimacy; functional but empty.");
        AddPairing("SAWRP", "IAWTE", "Challenging", "Independent operator + avoidant dreamer. Operator's distance plus dreamer's chaos = no safety. Watch: dreamer's need for closeness can't be met.");
        AddPairing("SAWRP", "IAWRP", "High", "Two withdrawn operators. Both extremely independent and emotionally distant. Stable but likely lonely. Watch: complete emotional disconnection; isolation together.");
        AddPairing("SAWRP", "IAWRE", "Challenging", "Independent operator + disorganized dreamer. Operator's consistency attracts dreamer; dreamer's chaos overwhelms operator. Watch: operator eventually shuts down completely.");

        AddPairing("SAWRE", "SAWRE", "High", "Two distant watchers. Both emotionally attuned but private. Deep quiet understanding without much expression. Watch: risk of assuming you know each other when you don't.");
        AddPairing("SAWRE", "IETEPM", "Challenging", "Distant watcher + anxious pursuer. Watcher's distance triggers pursuer's anxiety. Risk: Pursuer chases observer, who steps further back. Watch: painful cycle.");
        AddPairing("SAWRE", "IETETE", "Challenging", "Distant watcher + anxious advocate. Advocate's intensity is too much for watcher; watcher withdraws. Watch: advocate feels unseen by observer.");
        AddPairing("SAWRE", "IETRP", "Good", "Distant watcher + anxious builder. Watcher notices builder's hidden worry. Good understanding but builder still doesn't ask for help. Watch: resentment festers.");
        AddPairing("SAWRE", "IETRE", "Good", "Distant watcher + anxious counselor. Both emotionally aware; watcher finally feels seen by counselor. Watch: counselor's need for reciprocal openness goes unmet.");
        AddPairing("SAWRE", "IAWTP", "Good", "Distant watcher + avoidant achiever. Both emotionally distant and work-focused. Stable but cold. Watch: zero real intimacy; just cohabitation.");
        AddPairing("SAWRE", "IAWTE", "Good", "Distant watcher + avoidant dreamer. Watcher's observation meets dreamer's periodic openness. Good balance but dreamer may still flee. Watch: dreamer's sabotage.");
        AddPairing("SAWRE", "IAWRP", "Good", "Distant watcher + withdrawn operator. Both emotionally unavailable. Stable, isolated. Watch: may become roommates with no emotional connection.");
        AddPairing("SAWRE", "IAWRE", "Challenging", "Distant watcher + disorganized dreamer. Watcher's careful observation doesn't prevent dreamer's chaos. Watch: watcher frustrated by unpredictability.");

        // Rows 9-16: Anxious-Avoidant types (IETEPM, IETETE, IETRP, IETRE, IAWTP, IAWTE, IAWRP, IAWRE)
        AddPairing("IETEPM", "IETEPM", "Challenging", "Two anxious pursuers. Both seek reassurance; both afraid of abandonment. Risk: Mutual anxiety spiral and mutual blame. Watch: neither can regulate the other.");
        AddPairing("IETEPM", "IETETE", "Challenging", "Anxious pursuer + anxious advocate. Both intense, both need reassurance. Risk: Escalating emotional chaos. Watch: arguments become about reassurance-seeking, not problem-solving.");
        AddPairing("IETEPM", "IETRP", "Challenging", "Anxious pursuer + anxious builder. Both pursue in different ways (emotionally vs practically). Risk: Mutual neediness with no relief. Watch: anxiety exhausts both.");
        AddPairing("IETEPM", "IETRE", "Good", "Anxious pursuer + anxious counselor. Counselor's care meets pursuer's need; pursuer's directness breaks counselor's silence. Watch: can work if counselor doesn't martyr.");
        AddPairing("IETEPM", "IAWTP", "Challenging", "Anxious pursuer + avoidant achiever. Classic pursue-withdraw dynamic. Risk: Endless cycle; pursuer chases, achiever works harder. Watch: no resolution, just escalation.");
        AddPairing("IETEPM", "IAWTE", "Challenging", "Anxious pursuer + avoidant dreamer. THE PURSUER-WITHDRAWER CYCLE. Risk: Extreme pain; most common agonizing dynamic. Watch: pursuer spirals; dreamer disappears; both hurt immensely.");
        AddPairing("IETEPM", "IAWRP", "Challenging", "Anxious pursuer + withdrawn operator. Pursuer's anxiety triggers operator's complete withdrawal. Risk: Extreme isolation from pursuer's perspective. Watch: operator feels invaded; pursuer feels abandoned.");
        AddPairing("IETEPM", "IAWRE", "Challenging", "Anxious pursuer + disorganized dreamer. Pursuer chases disorganized chaos; dreamer sabotages any stability. Risk: Chaotic painful cycles. Watch: neither can stabilize; both blame.");

        AddPairing("IETETE", "IETETE", "Challenging", "Two anxious advocates. Both emotionally intense, both need reassurance. Risk: Mutual flooding and escalation. Watch: can't de-escalate; argument spirals into emotional chaos.");
        AddPairing("IETETE", "IETRP", "Challenging", "Anxious advocate + anxious builder. Advocate's intensity meets builder's quiet anxiety. Risk: Advocate feels unmet; builder feels overwhelmed. Watch: communication breakdown.");
        AddPairing("IETETE", "IETRE", "Challenging", "Two anxious advocates (one reserved). Advocate's intensity triggers counselor's protective silence. Risk: Counselor shuts down under pressure. Watch: both feel unheard.");
        AddPairing("IETETE", "IAWTP", "Challenging", "Anxious advocate + avoidant achiever. Advocate's intensity drives achiever to work/distance. Risk: Severe pursue-withdraw. Watch: advocate feels completely rejected and alone.");
        AddPairing("IETETE", "IAWTE", "Challenging", "Anxious advocate + avoidant dreamer. Advocate pursues; dreamer flees. Risk: THE CYCLE — extreme emotional pain for both. Watch: most painful common pattern in relationships.");
        AddPairing("IETETE", "IAWRP", "Challenging", "Anxious advocate + withdrawn operator. Advocate pours emotional energy into stone wall. Risk: Advocate exhaustion and resentment. Watch: advocate feels invisible and worthless.");
        AddPairing("IETETE", "IAWRE", "Challenging", "Anxious advocate + disorganized dreamer. Advocate's intensity meets dreamer's unpredictability. Risk: Chaotic emotional flooding. Watch: both drained; relationship destabilizes.");

        AddPairing("IETRP", "IETRP", "Challenging", "Two anxious builders. Both work hard, both quiet about doubt. Risk: Silent resentment accumulates. Watch: anxiety goes unaddressed; explodes unexpectedly.");
        AddPairing("IETRP", "IETRE", "Good", "Anxious builder + anxious counselor. Counselor notices builder's worry and addresses it gently. Watch: builder may still not ask; counselor may martyr.");
        AddPairing("IETRP", "IAWTP", "Challenging", "Anxious builder + avoidant achiever. Both work-focused; achiever's avoidance triggers builder's anxiety. Watch: silent resentment in both; no resolution.");
        AddPairing("IETRP", "IAWTE", "Challenging", "Anxious builder + avoidant dreamer. Builder's steadiness attracts dreamer; dreamer's fear triggers builder's anxiety. Watch: dreamer sabotages builder's effort.");
        AddPairing("IETRP", "IAWRP", "Challenging", "Anxious builder + withdrawn operator. Builder's action-orientation unheard by operator's silence. Watch: builder's anxiety unmet; operator feels pressured.");
        AddPairing("IETRP", "IAWRE", "Challenging", "Anxious builder + disorganized dreamer. Builder seeks stability; dreamer brings chaos. Risk: Builder's confidence eroded. Watch: builder exhausted trying to stabilize dreamer.");

        AddPairing("IETRE", "IETRE", "Challenging", "Two anxious counselors. Both emotionally attuned; both need reassurance. Risk: Can get stuck in feelings; analysis without action. Watch: mutual anxiety regulation fails when both doubt themselves.");
        AddPairing("IETRE", "IAWTP", "Challenging", "Anxious counselor + avoidant achiever. Counselor seeks emotional connection; achiever hides in work. Watch: counselor's care is unreturned; resentment builds.");
        AddPairing("IETRE", "IAWTE", "Challenging", "Anxious counselor + avoidant dreamer. Counselor cares for dreamer; dreamer's chaos and flight hurt counselor. Watch: counselor's martyr pattern; dreamer's guilt-driven return.");
        AddPairing("IETRE", "IAWRP", "Challenging", "Anxious counselor + withdrawn operator. Counselor offers emotional connection; operator provides nothing. Watch: one-sided emotional labor; counselor burns out.");
        AddPairing("IETRE", "IAWRE", "Challenging", "Anxious counselor + disorganized dreamer. Counselor tries to stabilize chaotic partner. Risk: Counselor exhaustion. Watch: counselor enables dreamer's avoidance of growth.");

        AddPairing("IAWTP", "IAWTP", "Good", "Two avoidant achievers. Both work-focused, emotionally distant, parallel lives. Stable but disconnected. Watch: relationship becomes roommate situation; zero intimacy.");
        AddPairing("IAWTP", "IAWTE", "Challenging", "Avoidant achiever + avoidant dreamer. Achiever's distance plus dreamer's chaos = no safety. Watch: dreamer feels unheard; achiever feels chaotic partner can't be handled.");
        AddPairing("IAWTP", "IAWRP", "Good", "Two avoidant achievers/operators (different focus). Both emotionally distant and independent. Extremely stable but isolated. Watch: zero real intimacy; functional cohabitation.");
        AddPairing("IAWTP", "IAWRE", "Challenging", "Avoidant achiever + disorganized dreamer. Achiever's consistency attracts dreamer; dreamer's chaos repels achiever. Watch: achiever shuts down completely eventually.");

        AddPairing("IAWTE", "IAWTE", "Challenging", "Two avoidant dreamers (fearful-avoidant). Both want closeness but fear it. Risk: Unpredictable push-pull hell. Watch: relationship oscillates between intense closeness and complete distance; chaos reigns.");
        AddPairing("IAWTE", "IAWRP", "Challenging", "Avoidant dreamer + withdrawn operator. Dreamer needs emotional openness; operator provides none. Watch: dreamer feels invisible; operator feels chaotic partner is unsafe.");
        AddPairing("IAWTE", "IAWRE", "Challenging", "Two disorganized dreamers (both fearful-avoidant). Chaos × 2. Risk: Relationship is volatile and unpredictable. Watch: both sabotage when good; both blame when bad.");

        AddPairing("IAWRP", "IAWRP", "High", "Two withdrawn operators. Both emotionally distant, independent, practical. Extremely stable but likely lonely together. Watch: parallel lives with zero real intimacy; stable isolation.");
        AddPairing("IAWRP", "IAWRE", "Challenging", "Withdrawn operator + disorganized dreamer. Operator's stability attracts dreamer; dreamer's chaos destabilizes operator. Watch: operator eventually shuts down entirely.");

        AddPairing("IAWRE", "IAWRE", "Challenging", "Two disorganized dreamers. Chaos + chaos. Risk: Relationship is volatile, unpredictable, painful. Watch: both suffer; neither can stabilize the other; mutual sabotage.");
    }

    internal static PairCompatibility GetCompatibility(string typeCode1, string typeCode2)
    {
        if (Matrix.TryGetValue((typeCode1, typeCode2), out var compat))
        {
            return compat;
        }

        // Fallback: if one is secure, compatibility is Good; otherwise Challenging
        if (typeCode1.StartsWith("S") || typeCode2.StartsWith("S"))
        {
            return new("Good", "Fallback: at least one secure partner usually stabilizes the dynamic.");
        }

        return new("Challenging", "Fallback: both insecure types may struggle without external support.");
    }
}
