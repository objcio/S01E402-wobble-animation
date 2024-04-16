import SwiftUI

extension View {
    func asIcon(color: Color) -> some View {
        self
            .font(.largeTitle)
            .symbolVariant(.fill)
            .foregroundStyle(.white)
            .padding()
            .frame(width: 64, height: 64)
            .background(color.gradient, in: .rect(cornerRadius: 16, style: .continuous))
    }

    func inlineBadge(_ value: Int, alignment: Alignment) -> some View {
        overlay(alignment: alignment) {
            Badge(value: value)
                .alignmentGuide(alignment.vertical, computeValue: { dimension in
                    dimension[VerticalAlignment.center]
                })
                .alignmentGuide(alignment.horizontal, computeValue: { dimension in
                    dimension[HorizontalAlignment.center]
                })
                .fixedSize()
        }
    }

    func badge(_ value: Int, alignment: Anchor<CGPoint>.Source = .topTrailing) -> some View {
        modifier(BadgeHelper(alignment: alignment, view: AnyView(            Badge(value: value)
            .fixedSize())))
    }

    func overlayBadges() -> some View {
        overlayPreferenceValue(BadgePreferenceKey.self, { badges in
            GeometryReader { proxy in
                ForEach(badges) { badge in
                    let p = proxy[badge.position]
                    badge.view
                        .position(p)
                }
            }
        })
    }
}

struct BadgeHelper: ViewModifier {
    var alignment: Anchor<CGPoint>.Source
    var view: AnyView
    @Namespace private var ns

    func body(content: Content) -> some View {
        content.anchorPreference(key: BadgePreferenceKey.self, value: alignment, transform: { anchor in
            return [BadgeValue(view: view, position: anchor, id: ns)]
        })
    }
}

struct Badge: View {
    var value: Int
    @ScaledMetric(relativeTo: .body) private var minWidth = 24
    var body: some View {
        Text("\(value)")
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(minWidth: minWidth)
            .frame(height: minWidth)
            .background(.red.gradient, in: .capsule)
    }
}

struct BadgeValue: Identifiable {
    var view: AnyView
    var position: Anchor<CGPoint>
    var id: Namespace.ID
}

struct BadgePreferenceKey: PreferenceKey {
    static var defaultValue: [BadgeValue] = []
    static func reduce(value: inout [BadgeValue], nextValue: () -> [BadgeValue]) {
        value.append(contentsOf: nextValue())
    }
}

struct Wobble: ViewModifier, Animatable {
    var value: Double
    var active: Bool

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        let rotation = sin(value * 2 * .pi) * 10
        return content
            .rotationEffect(active ? .degrees(rotation) : .zero)
            .transaction { transaction in
                transaction.animation = nil
            }
    }
}

extension View {
    func wobble(active: Bool) -> some View {
        self.phaseAnimator([-10, 10]) { content, phase in
            content
                .rotationEffect(.degrees(active ? phase : 0))
        } animation: { _ in
            .default
        }

    }

    func wobbleAlt(active: Bool) -> some View {
        modifier(Wobble(value: active ? 1 : 0, active: active))
            .animation(active ? .linear.repeatForever(autoreverses: false) : .linear, value: active)
    }
}

struct ContentView: View {
    @State private var editing = false

    var body: some View {
        HStack {
            Image(systemName: "globe")
                .asIcon(color: .blue)
                .wobble(active: editing)
                .onLongPressGesture {
                    editing = true
                }
            Image(systemName: "phone")
                .asIcon(color: .green)
                .badge(1000, alignment: .topTrailing)
            Image(systemName: "message")
                .asIcon(color: .green)
            Image(systemName: "book")
                .asIcon(color: .orange)
                .wobbleAlt(active: editing)
        }
        .overlayBadges()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .onTapGesture {
            editing = false
        }
    }
}

#Preview {
    ContentView()
}
